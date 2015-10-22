//
//  Photo.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import CoreData
import Foundation

@objc(Photo)
class Photo: ParseObject
{


	func likedBy(user: PFUser?) -> Bool
	{
		guard user != nil else { return false }
		guard self.usersLiked != nil else { return false }

		var liked = self.usersLiked!.contains(user!.objectId!)
		if (user!["phone_number"] != nil && self.usersLiked!.contains((user!["phone_number"] as! String))) {
			liked = true
		} else if user!["facebook_id"] != nil && self.usersLiked!.contains((user!["facebook_id"] as! NSNumber).stringValue) {
			liked = true
		}

		return liked
	}


}
