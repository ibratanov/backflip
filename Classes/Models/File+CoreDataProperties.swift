//
//  File+CoreDataProperties.swift
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

extension File {

    @NSManaged var name: String?
    @NSManaged var url: String?

}
