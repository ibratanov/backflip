//
//  BFBrowseEventCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

public class BFBrowseEventCell : UITableViewCell
{
	
	/**
	 * Cell Identifier
	 *
	 * A static cell reuse identifier that can be used as part of `dequeueReusableCellWithReuseIdentifier:forIndexPath:`
	*/
	public static let reuseIdentifier: String = "featured-event-cell-identifier"
	
	
	/**
	 * Content Height
	*/
	public static let contentHight: CGFloat = 88.0
	
	/**
	 * Background Image View
	*/
	public var backgroundImageView: UIImageView!
	
	
	private var gradientView: BFGradientView!
	
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.loadView()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		self.loadView()
	}
	
	
	private func loadView()
	{
		self.gradientView = BFGradientView(frame: CGRectZero)
		self.gradientView.colours = [UIColor.clearColor(), UIColor.blackColor().colorWithAlphaComponent(0.8)]
		
		self.backgroundImageView = UIImageView(frame: CGRectZero)
		self.backgroundImageView.contentMode = .ScaleToFill
		
		self.contentView.addSubview(self.backgroundImageView)
		self.contentView.insertSubview(self.gradientView, atIndex: 1)
	}
	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.gradientView.frame = self.contentView.frame
		self.backgroundImageView.frame = self.contentView.frame
		
		self.contentView.sendSubviewToBack(self.backgroundImageView)
	}
}
