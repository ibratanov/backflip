//
//  BFWebviewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-23.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import WebKit
import Foundation

public class BFWebviewController : UIViewController
{
	
	/**
	 * Webview
	*/
	public let webView: WKWebView = WKWebView()
	
	
	public override func loadView()
	{
		super.loadView()
		
		self.view = self.webView
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
	}
	
	public func loadUrl(url: NSURL)
	{
		self.webView.loadRequest(NSURLRequest(URL:url))
	}
	
	
	/**
	 * Button touch event
	*/
	public func doneButtonPressed(sender: AnyObject?)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
