//
//  PersistentLocation+CoreDataProperties.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Foundation
import CoreData


extension PersistentLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentLocation> {
        return NSFetchRequest<PersistentLocation>(entityName: "PersistentLocation")
    }

    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var id: String?
    @NSManaged public var coordinate: PersistentCoordinate?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension PersistentLocation {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: PersistentImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: PersistentImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
