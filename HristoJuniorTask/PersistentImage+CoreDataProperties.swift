//
//  PersistentImage+CoreDataProperties.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Foundation
import CoreData


extension PersistentImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentImage> {
        return NSFetchRequest<PersistentImage>(entityName: "PersistentImage")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var location: PersistentLocation?

}
