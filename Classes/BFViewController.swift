//
//  BFViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation

public class BFViewController : UIViewController
{
	let flurryParameters : [NSObject : AnyObject] = ["Author": UIDevice.currentDevice().uniqueDeviceIdentifier(), "User_Status": "Registered"]
	
	
	override public func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		Flurry.logEvent("Screen_\(self.title)", withParameters: flurryParameters, timed: true)
	}
	
	override public func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		Flurry.endTimedEvent("Screen_\(self.title)", withParameters: nil);
	}
}


public class BFCollectionViewController : UICollectionViewController
{
    let flurryParameters : [NSObject : AnyObject] = ["Author": UIDevice.currentDevice().uniqueDeviceIdentifier(), "User_Status": "Registered"]
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        Flurry.logEvent("Screen_\(self.title)", withParameters: flurryParameters, timed: true)
    }
    
    override public func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        Flurry.endTimedEvent("Screen_\(self.title)", withParameters: nil);
    }
}
