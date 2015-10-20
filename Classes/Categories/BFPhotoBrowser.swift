//
//  BFPhotoBrowser.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-19.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation
import SKPhotoBrowser


public class BFPhotoBrowser : SKPhotoBrowser
{
	
	public var likeButton : UIBarButtonItem?
	
	public var likeLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 60, 21))
	
	public var shareButton : UIBarButtonItem?
	public var trashButton : UIBarButtonItem?
	
	
	
	override public func loadView()
	{
		super.loadView()
		
		likeLabel.font = UIFont.systemFontOfSize(18)
		likeLabel.textColor = UIColor.whiteColor()
	}
	
	
	override public func viewDidLoad()
	{
		super.viewDidLoad()
	}
	
	
	override public func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		likeButton?.tintColor = UIColor.whiteColor()
		shareButton?.tintColor = UIColor.whiteColor()
		trashButton?.tintColor = UIColor.whiteColor()
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
		let toolbarItems : [UIBarButtonItem] = [shareButton!, flexSpace, likeButton!, UIBarButtonItem(customView: likeLabel), flexSpace, trashButton!]
		
		self.toolBar.setItems(toolbarItems, animated: true)
	}
	

}