//
//  PhotoBrowserItemViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


public class PhotoBrowserItemViewController : UIViewController
{
	
	public weak var photo : PFObject?
	
	public var imageView : UIImageView = UIImageView(frame: CGRectZero)
	
	
	override public func loadView()
	{
		super.loadView()
		
		imageView.contentMode = .ScaleAspectFit
		self.view.addSubview(imageView)
	}
	
	override public func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		
		imageView.frame = self.view.frame
	}
	
}