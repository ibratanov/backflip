//
//  BFGradientView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-04.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation

class BFGradientView : UIView
{
	
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		self.setupGradient()
	}

	required init?(coder aDecoder: NSCoder)
	{
	    super.init(coder: aDecoder)
		
		self.setupGradient()
	}

	
	func setupGradient()
	{
		let gradient: CAGradientLayer = CAGradientLayer()
		gradient.frame = self.bounds
		gradient.colors = [UIColor(red:0.447,  green:0.314,  blue:0.643, alpha:1).CGColor, UIColor(red:0.263,  green:0.824,  blue:0.859, alpha:1).CGColor]
		self.layer.insertSublayer(gradient, atIndex: 0)
	}
}
