//
//  Image.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-05.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import Foundation

class Image: NSObject, UIActivityItemSource
{
	var text : String = "";
	var thumbnail : PFFile = PFFile.new()
	var likes : Int = 0
	var objectId : String?
	var createdAt : NSDate? = NSDate.new()
	var image : PFFile = PFFile.new()
	var likedBy : [String] = []
	
	// Constructor
	init(text: String) {
		self.text = text;
	}
	
	
	// Activity placeholder content
	func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject
	{
		return text;
	}
	
	// Content depending on input
	func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject?
	{
		
		if (activityType == UIActivityTypeMail) {
			return "<html><body>"+text+" <br />Sent via <a href=\"http://getbackflip.com/\">Backflip</a>"+"</body></html>";
		} else if (activityType == UIActivityTypePostToTwitter) {
			return text+" via @getbackflip";
		}
		
		return text;
	}
	
	
	func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String
	{
		
		if (activityType == UIActivityTypeMail) {
			return "Photo on Backflip";
		} else if (activityType == UIActivityTypePostToTwitter) {
			return text+" via @getbackflip";
		}
		
		return text;
	}
	
}