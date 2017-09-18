//
//  PersistentLocation+CoreDataClass.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreData
import CoreLocation
import GoogleMaps

@objc(PersistentLocation)
public class PersistentLocation: NSManagedObject {
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init?(geocoding: Geocoding, insertInto context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: PersistentLocation.self), in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        map(geocoding)
    }
    
    init?(id: String?, address: String?, city: String?, country: String?, coordinate: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: PersistentLocation.self), in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        self.id = id
        self.address = address
        self.city = city
        self.country = country
        self.coordinate = PersistentCoordinate(coordinate: coordinate, insertInto: context)
    }
    
    func map(_ geocoding: Geocoding) {
        id = geocoding.id
        address = geocoding.address
        city = geocoding.city
        country = geocoding.country
    }
    
    static func load(in context: NSManagedObjectContext, all successBlock: @escaping ([PersistentLocation])->()) {
        load(in: context, all: successBlock, failureBlock: nil)
    }
    
    static func load(in context: NSManagedObjectContext, all successBlock: @escaping ([PersistentLocation])->(), failureBlock:((Error)->())?) {
        context.perform {
            do {
//                if let locations = try context.fetch(fetchRequest()) as? [PersistentLocation], locations.count > 0 {
//                    successBlock(locations)
//                    return
//                }
//                failureBlock?(NSError(domain: "No locations have been saved", code: 0, userInfo: nil))
                successBlock(try context.fetch(fetchRequest()))
            } catch let error {
                failureBlock?(error)
            }
        }
    }
    
    func delete(in context: NSManagedObjectContext) {
        delete(in: context, successBlock: nil, failureBlock: nil)
    }
    
    func delete(in context: NSManagedObjectContext, successBlock:@escaping ()->()) {
        delete(in: context, successBlock: successBlock, failureBlock: nil)
    }
    
    func delete(in context: NSManagedObjectContext, successBlock:(()->())?, failureBlock:((Error)->())?) {
        context.perform {
            context.delete(self)
            do {
                try _ = context.save()
            } catch let error {
                failureBlock?(error)
                return
            }
            successBlock?()
        }
    }

    func add(_ image: UIImage, in context: NSManagedObjectContext) {
//        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = UIImageJPEGRepresentation(image, 1), let image = PersistentImage(data: data as NSData, insertInto: context) else {
                return
            }
//            DispatchQueue.main.async {
                self.addToImages(image)
//            }
//        }
    }
    
    func getImagesDataAsUIImage() -> [UIImage]? {
        guard images != nil && images!.count > 0 else {
            return nil
        }
        var result = [UIImage]()
        for element in images! {
            if let data = (element as? PersistentImage)?.data, let image = UIImage(data: data as Data) {
                result.append(image)
            }
        }
        return result
    }
}

extension Array where Element: PersistentLocation {
    
    func create(inBlock successBlock: @escaping ([GMSMarker])->()) {
        var markers: [GMSMarker]?
        for location in self {
            guard let coordinate = location.coordinate else {
                continue
            }
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
            marker.userData = location
            marker.title = location.address
            marker.icon = GMSMarker.markerImage(with: .blue)
            marker.isDraggable = true
            if markers == nil {
                markers = []
            }
            markers?.append(marker)
        }
        if markers != nil {
            successBlock(markers!)
        }
    }
}
