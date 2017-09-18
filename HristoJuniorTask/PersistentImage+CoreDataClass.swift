//
//  PersistentImage+CoreDataClass.swift
//  HristoJuniorTask
//
//  Created by Hristo Hristov on 17/9/17.
//  Copyright © 2017 allterco. All rights reserved.
//

import Foundation
import CoreData

@objc(PersistentImage)
public class PersistentImage: NSManagedObject {
    
    fileprivate override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init?(data: NSData, insertInto context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: PersistentImage.self), in: context) else {
            return nil
        }
        super.init(entity: entity, insertInto: context)
        self.data = data
    }
}
