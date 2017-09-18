//
//  PersistentCoordinate+CoreDataClass.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import CoreData
import CoreLocation

@objc(PersistentCoordinate)
public class PersistentCoordinate: NSManagedObject {
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init?(coordinate: CLLocationCoordinate2D, insertInto context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: PersistentCoordinate.self), in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        map(coordinate)
    }
    
    func map(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}
