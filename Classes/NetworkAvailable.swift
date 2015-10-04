//
//  NetworkAvailable.swift
//  Backflip
//
//  Created by Jonathan Arlauskas on 2015-06-22.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import SystemConfiguration

public class NetworkAvailable {
    
    
    class func networkConnection() -> Bool
	{
		return isConnectedToNetwork()
	}
	
	class func isConnectedToNetwork() -> Bool
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
	
	
    class func networkAlert(title:String,error: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok" , style: .Default, handler: nil))
        
        return alert
        
    }


}
