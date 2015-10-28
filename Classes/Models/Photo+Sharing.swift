//
//  Photo+Sharing.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation
import Parse


extension Photo : UIActivityItemSource
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
			return "<html><body>Image posted via <a href=\"http://getbackflip.com/\">Backflip</a>"+"</body></html>"
		} else if (activityType == UIActivityTypePostToTwitter) {
            let config = PFConfig.currentConfig()
            return "Check out this photo from "+self.event!.name!+"\n@getbackflip \(config["twitter_share_content"]!)"
		} else if (activityType == UIActivityTypePostToFacebook) {
			return ""
		}
		
		return ""
	}
	
	private func shareSubject(activityType: String?) -> String
	{
		if (activityType == UIActivityTypeMail) {
			return "Check out this photo from Backflip!"
		}
		
		return ""
	}
	
}