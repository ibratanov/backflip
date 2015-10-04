//
//  ReportImage.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-05.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Foundation

class ReportImageActivity : UIActivity
{
	
	override init() {
		self.text = ""
		
	}
	
	var text:String?
	
	
	override func activityType()-> String {
		return NSStringFromClass(self.classForCoder)
	}
	
	override func activityImage()-> UIImage
	{
		return UIImage(named: "report-image-activity-icon")!;
	}
	
	override func activityTitle() -> String
	{
		return "Report Image";
	}
	
	override class func activityCategory() -> UIActivityCategory{
		return UIActivityCategory.Action
	}
	
	func getURLFromMessage(message:String)-> NSURL
	{
		var url = "whatsapp://"
		
		if (message != "")
		{
			url = "\(url)send?text=\(message)"
		}
		
		return NSURL(string: url)!
	}
	
	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool
	{
		return true;
	}
	
	override func prepareWithActivityItems(activityItems: [AnyObject])
	{
		NSNotificationCenter.defaultCenter().postNotificationName("BFImageReportActivitySelected", object: nil)
	}
}