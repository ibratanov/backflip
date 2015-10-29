//
//  PopoverView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class PopoverView : BFViewController, UIPopoverPresentationControllerDelegate
{
	
	init()
	{
		super.init(nibName: nil, bundle: nil)
		
		self.modalPresentationStyle = .Popover
		self.popoverPresentationController?.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
	{
		return .None
	}
}

