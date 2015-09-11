//
//  PFObject+CoreDataProperties.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright © 2015 Backflip. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension ParseObject {

    @NSManaged var createdAt: NSDate?
    @NSManaged var objectId: String?
    @NSManaged var updatedAt: NSDate?
	@NSManaged var enabled : NSNumber?

}
