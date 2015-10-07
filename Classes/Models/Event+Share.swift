//
//  Event.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation
import CoreData

extension Event : UIActivityItemSource
{

	//-------------------------------------
	// MARK: UIActivityItemSource
	//-------------------------------------
	
	func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject
	{
		return shareText(nil)
	}
	
	func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject?
	{
		return shareText(activityType)
	}
	
	func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String
	{
		return shareSubject(activityType)
	}
	
	
	
	
	//-------------------------------------
	// MARK: Private
	//-------------------------------------
	
	private func shareText(activityType: String?) -> String
	{
		if (activityType == UIActivityTypeMail) {
            return "<html><body>Check out the photos from \(self.name!) on Backflip! \(inviteUrl!)</body></html>"
		} else if (activityType == UIActivityTypePostToTwitter) {
			return "Check out the photos from '\(self.name!)' on @getbackflip \(inviteUrl!) #backflip"
		}
		
		
		return "Check out the photos from \(self.name!) on Backflip!"
	}
	
	private func shareSubject(activityType: String?) -> String
	{
		if (activityType == UIActivityTypeMail) {
			return "Photos from \(self.name!)"
		}
		
		return ""
	}
	
}