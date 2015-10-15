//
//  UIDevice+Extensions.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-15.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Locksmith
import Foundation


extension UIDevice
{
	
	func uniqueDeviceIdentifier() -> String
	{
		let dictionary = Locksmith.loadDataForUserAccount("backflip-account")
		if (dictionary != nil && dictionary!["unique_identifier"] != nil) {
			return dictionary!["unique_identifier"] as! String
		} else {
			
			do {
				try Locksmith.saveData(["unique_identifier": UIDevice.currentDevice().identifierForVendor!.UUIDString], forUserAccount: "backflip-account")
			} catch {
				print("Error saving device identifier to keychain")
			}
			
			return UIDevice.currentDevice().identifierForVendor!.UUIDString
		}
	}

	
}
