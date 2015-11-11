//
//  BFGradientView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-04.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation

public class BFGradientView : UIView
{
	
	/**
	 * Gradient Colors
	*/
	public var colours: [UIColor] = [] {
		didSet {
			
			var __colours: [CGColor] = []
			for colour in colours {
				__colours.append(colour.CGColor)
			}
			
			self.gradientLayer.colors = __colours
		}
	}
	
	/**
	 * Gradient Layer
	*/
	private let gradientLayer = CAGradientLayer()
	
	
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		self.layer.insertSublayer(self.gradientLayer, atIndex: 0)
	}

	required public init?(coder aDecoder: NSCoder)
	{
	    super.init(coder: aDecoder)
		
		self.layer.insertSublayer(self.gradientLayer, atIndex: 0)
	}
	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.gradientLayer.frame = self.frame
	}

}
