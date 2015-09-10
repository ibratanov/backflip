//
//  Event+CoreDataProperties.swift
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

extension Event {

    @NSManaged var endTime: NSDate?
    @NSManaged var live: NSNumber?
    @NSManaged var name: String?
    @NSManaged var startTime: NSDate?
    @NSManaged var venue: String?
    @NSManaged var attendees: NSSet?
    @NSManaged var geoLocation: GeoPoint?
    @NSManaged var photos: NSSet?

}
