//
//  Event.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation
import CoreData

@objc(Event)
public class Event: ParseObject
{

	var __cleanPhotos : [Photo] = [] // Caching, yay speed!
	
	
	var cleanPhotos: [Photo] {
		get {
			guard self.photos != nil && self.photos?.count > 0 else { return [] }
			
			guard __cleanPhotos.count < 1 else { return __cleanPhotos }
			
			let _photos = self.photos!.allObjects as? [Photo]
			var cleanPhotos : [Photo] = []
			for photo in _photos! {
				if (photo.flagged?.boolValue == false && photo.enabled?.boolValue == true) {
					cleanPhotos.append(photo)
				}
			}
			
			__cleanPhotos = cleanPhotos // Cache
			return cleanPhotos
		}
	}
	
	
}
