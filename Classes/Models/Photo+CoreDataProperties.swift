//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var caption: String?
    @NSManaged var flagged: NSNumber?
    @NSManaged var reporter: String?
    @NSManaged var uploader: String?
    @NSManaged var upvoteCount: NSNumber?
    @NSManaged var usersLiked: String?
    @NSManaged var image: File?
    @NSManaged var thumbnail: File?
    @NSManaged var event: Event?

}
