//
//  Album.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-05.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Foundation

class AlbumShare: NSObject, UIActivityItemSource
{
	var text : String = "";
	var url : String = "";
	
	// Constructor
	init(text: String, url: String) {
		self.text = text;
		self.url = url;
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
			return "<html><body>"+text+"<a href=\"\(url)\">Backflip!</a>"+"</body></html>";
		} else if (activityType == UIActivityTypePostToTwitter) {
			return text+"@getbackflip!";
		}
		
		return text+"Backflip!";
	}
	
	
	func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String
	{
		
		if (activityType == UIActivityTypeMail) {
			return "Photo on Backflip";
		} else if (activityType == UIActivityTypePostToTwitter) {
			return text+"@getbackflip!";
		}
		
		return text+"Backflip!";
	}
	
}