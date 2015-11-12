//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var caption: String?
    @NSManaged var flagged: NSNumber?
    @NSManaged var reporter: String?
    @NSManaged var uploader: String?
    @NSManaged var upvoteCount: NSNumber?
    @NSManaged var usersLiked: String?
    @NSManaged var event: Event?
    @NSManaged var image: File?
    @NSManaged var thumbnail: File?

}
