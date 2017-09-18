//
//  PersistentCoordinate+CoreDataProperties.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Foundation
import CoreData


extension PersistentCoordinate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentCoordinate> {
        return NSFetchRequest<PersistentCoordinate>(entityName: "PersistentCoordinate")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var location: PersistentLocation?

}
