//
//  Event+CoreDataProperties.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-12.
//  Copyright © 2015 Backflip. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var endTime: NSDate?
    @NSManaged var inviteUrl: String?
    @NSManaged var live: NSNumber?
    @NSManaged var name: String?
	@NSManaged var eventDescription: String?
    @NSManaged var owner: String?
    @NSManaged var startTime: NSDate?
    @NSManaged var venue: String?
    @NSManaged var attendees: NSSet?
    @NSManaged var geoLocation: GeoPoint?
    @NSManaged var photos: NSSet?
    @NSManaged var features: NSSet?
    @NSManaged var tags: NSSet?
	@NSManaged var ticketUrl: String?
	@NSManaged var previewImage: File?
	@NSManaged var featureImage: File?
	@NSManaged var regionRadius: NSNumber?

}
