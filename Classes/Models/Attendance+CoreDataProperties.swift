//
//  Attendance+CoreDataProperties.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-31.
//  Copyright © 2015 Backflip. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Attendance {

    @NSManaged var attendeeId: String?
    @NSManaged var event: Event?

}
