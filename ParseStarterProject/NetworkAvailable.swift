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
    
    
    class func networkConnection() -> Bool {
        
        var address = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0 , 0, 0, 0, 0, 0, 0, 0))
        address.sin_len = UInt8(sizeofValue(address))
        address.sin_family = sa_family_t(AF_INET)
        
        let defRouteReachability = withUnsafePointer(&address) {
            
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
            
        }
        
        
        var flag: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defRouteReachability, &flag) == 0 {
            
            return false
            
        }
        
        let reachable = (flag & UInt32(kSCNetworkFlagsReachable)) != 0
        let noConnection = (flag & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return reachable && !noConnection
  
        
    }
    
    
    class func networkAlert(title:String,error: String) -> UIAlertController {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok" , style: .Default, handler: nil))
        
        return alert
        
    }


}
