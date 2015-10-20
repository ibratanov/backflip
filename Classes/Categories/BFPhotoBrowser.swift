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
	
	public var likeButton : DOFavoriteButton = DOFavoriteButton(frame: CGRectMake(0, 0, 31, 30), image: UIImage(named: "PUFavoriteOn"))
	public var likeLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 60, 21))
	
	public var shareButton : UIBarButtonItem?
	public let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: nil, action: nil)
	
	
	override public func loadView()
	{
		super.loadView()
		
		likeLabel.font = UIFont.systemFontOfSize(18)
		likeLabel.textColor = UIColor.whiteColor()
		
		likeButton.imageColorOff = UIColor.whiteColor()
		likeButton.imageColorOn = UIColor(red:1,  green:0.412,  blue:0.384, alpha:1)
		likeButton.lineColor = UIColor(red:1,  green:0.412,  blue:0.384, alpha:1)
		likeButton.circleColor = UIColor(red:1,  green:0.412,  blue:0.384, alpha:1)
	}
	
	
	override public func viewDidLoad()
	{
		super.viewDidLoad()
		
		trashButton.width = 40
	}
	
	
	override public func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
		let likeBarButton = UIBarButtonItem(customView: likeButton)
		likeBarButton.width = 46
		likeBarButton.customView?.frame = CGRectMake(0, 0, 31, 30)
		likeBarButton.customView?.layer.borderWidth = 1
		likeBarButton.customView?.layer.borderColor = UIColor.redColor().CGColor
		
		let toolbarItems : [UIBarButtonItem] = [shareButton!, flexSpace, likeBarButton, UIBarButtonItem(customView: likeLabel), flexSpace, trashButton]
		
		self.toolBar.setItems(toolbarItems, animated: true)
	}
	

}