//
//  LoginViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation

class LoginViewController : UIViewController
{
	
	/**
	 * Activity indicator
	*/
	@IBOutlet weak var activityIndicator : UIActivityIndicatorView!
	
	
	/**
	* Bonjour Server
	*/
	internal var bonjourServer : BFBonjourServer = BFBonjourServer()
	
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		let serverStarted = self.bonjourServer.startServer()
		if (serverStarted) {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountLoggedIn", name: "BFBonjourServerAccountDidLogin", object: nil)
		} else {
			print("Server didn't start :(")
		}
		
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		self.view.bringSubviewToFront(activityIndicator)
	}
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		self.bonjourServer.stopServer()
	}

	
	func accountLoggedIn()
	{
		// Show login screen again..
		let storyboard = UIStoryboard(name: "Main-TV", bundle: NSBundle.mainBundle())
		let tabbarController = storyboard.instantiateViewControllerWithIdentifier("tabbar-controller")
		
		let window = UIApplication.sharedApplication().windows.first
		if (window != nil) {
			window?.rootViewController = tabbarController
		}
	}
}

