//
//  Event.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation


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
			return "<html><body>Join me at '"+self.name!+"'"+"</body></html>"
		} else if (activityType == UIActivityTypePostToTwitter) {
			return "Join me using @getbackflip at '"+self.name!+"' #backflip"
		}
		
		
		return "Join me at '"+self.name!+"'"
	}
	
	private func shareSubject(activityType: String?) -> String
	{
		if (activityType == UIActivityTypeMail) {
			return self.name!
		}
		
		return ""
	}
	
}