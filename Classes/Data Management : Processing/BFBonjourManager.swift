//
//  BFBonjourManager.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-30.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import UIKit
import Foundation

public class BFBonjourManager : NSObject
{
	
	public static let sharedManager : BFBonjourManager = BFBonjourManager.init()
	
	private let bonjourClient = BFBonjourClient.init()
	
	
	private override init()
	{
		super.init()
	}
	
	
	public func startServiceDiscovery()
	{
		guard FEATURE_ENABLE_BONJOUR == true else { return }
		
		guard PFUser.currentUser() != nil else { return }
		
		self.bonjourClient.incomingBlock = { (incomingString) -> Void in
			print("👻 bonjour service recived text '\(incomingString)'")
		}
		
		
		self.bonjourClient.startServiceBrowserWithDiscovery({ (netService) -> Void in
			print("👀 Found service of type `\(netService.type)`, with name `\(netService.name)` broadcasting on :\(netService.port)");
			
			let alertController = UIAlertController(title: "Backflip TV", message: "The Apple TV '\(netService.name)' is requesting account authorization, continue?", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Decline", style: .Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Grant", style: .Default, handler: { (alertAction) -> Void in
				self.bonjourClient.openStreamsForService(netService)
				
				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
				dispatch_after(delayTime, dispatch_get_main_queue()) {
					
					let payload : [String: AnyObject] = ["account":["objectId": PFUser.currentUser()!.objectId!, "phone_number": PFUser.currentUser()!["phone"]]]
					print("Payload = \(payload)")
					
					var JSONPayload : NSData?
					do {
						JSONPayload = try NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
					} catch {
						print("JSON error.. try again?")
					}
					
					if (JSONPayload != nil) {
						self.bonjourClient.streamText("base64:"+JSONPayload!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)))
					}
				}
			}))
			
			let window : UIWindow? = UIApplication.sharedApplication().windows.first!
			window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
		})
	}

	
}
