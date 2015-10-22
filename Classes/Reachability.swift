//
//  Network.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-12.
//  Copyright (c) 2015 Backflip Inc. All rights reserved.
//

import Foundation
import SystemConfiguration


public class Reachability
{

	public class func validNetworkConnection() -> Bool
	{
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
			SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
		}
		var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
		if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
			return false
		}
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		return (isReachable && !needsConnection)
	}


	public class func presentUnavailableAlert() -> Void
	{
		let alertViewController = UIAlertController(title: "Network Connection", message: "", preferredStyle: .Alert)
		alertViewController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))


		let window = UIApplication.sharedApplication().windows.first
		window?.rootViewController?.presentViewController(alertViewController, animated: true, completion: nil)
	}

}



@available(*, deprecated=1.0, renamed="Reachability")
public class NetworkAvailable
{

	@available(*, deprecated=1.0, renamed="validNetworkConnection")
	public class func networkConnection() -> Bool
	{
		return Reachability.validNetworkConnection()
	}

	@available(*, deprecated=1.0, obsoleted=1.0)
	public class func networkAlert(title: String, error: String) -> AnyObject?
	{
		return nil
	}
}

