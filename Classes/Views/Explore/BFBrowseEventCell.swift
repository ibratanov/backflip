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
	
	public var rightDetailLabel: UILabel!
	
	
	/**
	 * Gradient view, displayed infront of `backgroundImageview`
	*/
	private var gradientView: BFGradientView!
	
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
		
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
		
		
		self.textLabel?.textColor = UIColor.whiteColor()
		self.textLabel?.font = UIFont(name: "Lato-Regular", size: 18)
		
		self.detailTextLabel?.textColor = UIColor(red:0.859,  green:0.859,  blue:0.859, alpha:1)
		self.detailTextLabel?.font = UIFont(name: "Lato-Regular", size: 12)
		
		self.rightDetailLabel = UILabel(frame: CGRectZero)
		self.rightDetailLabel.textColor = UIColor(red:0.859,  green:0.859,  blue:0.859, alpha:1)
		self.rightDetailLabel.font = UIFont(name: "Lato-Regular", size: 15)
		self.rightDetailLabel.textAlignment = .Right
		self.contentView.addSubview(self.rightDetailLabel)
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
		
		self.textLabel?.frame = CGRectMake(10, 40, self.contentView.bounds.width/2 - 10, 30)
		self.detailTextLabel?.frame = CGRectMake(10, 58, self.contentView.bounds.width/2 - 10, 30)
		self.rightDetailLabel.frame = CGRectMake(self.contentView.bounds.width/2 - 10, 40, self.contentView.bounds.width/2, 30)
	}
}
