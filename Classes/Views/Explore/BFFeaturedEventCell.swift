//
//  BFFeaturedEventCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation


/**
	Collection View Cell
		Content View
			Size: 115x154
			Broder: #FF0000
			Corner Radius: 4
		ImageView
			Size: 115x116
		Label
			Size: 115x38
*/


public class BFFeaturedEventCell : UICollectionViewCell
{
	
	/**
		Cell Identifier

		A static cell reuse identifier that can be used as part of `dequeueReusableCellWithReuseIdentifier:forIndexPath:`
	*/
	public static let reuseIdentifier: String = "featured-event-cell-identifier"
	
	
	/**
		Imageview displayed in the background of the cell
		
		When no value is provided, `UIColor.lightGreyColor()` will be used instead
	*/
	public var imageView: UIImageView!
	
	
	/**
		Text label
	*/
	public var textLabel: UILabel!

	
	/**
		Background blur, used behind the `textLabel`
	*/
	private var blurBackgroundView: UIVisualEffectView!
	
	
	/**
	 * Overlay view, used primarily for when the cell is selected
	*/
	private var overlayView: UIView!
	
	

	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		self.setup()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		self.setup()
	}
	
	private func setup()
	{
		// Value initializtion
		self.imageView = UIImageView(frame: CGRectZero)
		self.textLabel = UILabel(frame: CGRectZero)
		self.blurBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
		self.overlayView = UIView(frame:  CGRectZero)
		
		// Adding to `contentView`
		self.contentView.addSubview(self.imageView)
		self.contentView.addSubview(self.blurBackgroundView)
		self.blurBackgroundView.contentView.addSubview(self.textLabel)
		self.contentView.addSubview(self.overlayView)
		self.contentView.bringSubviewToFront(self.overlayView)
		
		// Styling
		self.layer.cornerRadius = 4
		self.contentView.layer.masksToBounds = true
		self.contentView.layer.cornerRadius = 4
		self.contentView.layer.borderWidth = 0.5
		self.contentView.layer.borderColor = UIColor(red:0.941,  green:0.945,  blue:0.953, alpha:1).CGColor
		
		self.imageView.clipsToBounds = true
		self.imageView.layer.masksToBounds = true
		self.imageView.backgroundColor = UIColor(red:0.941,  green:0.945,  blue:0.953, alpha:1)
		
		self.blurBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
		self.blurBackgroundView.clipsToBounds = true
		self.blurBackgroundView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor
		self.blurBackgroundView.layer.borderWidth = 0

		self.textLabel.font = UIFont(name: "Lato-Regular", size: 11)
		self.textLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
		self.textLabel.textAlignment = .Center
		
		self.overlayView.backgroundColor = UIColor.lightGrayColor()
		self.overlayView.alpha = 0
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.imageView.frame = self.bounds
		self.blurBackgroundView.frame = CGRectMake(0, self.bounds.height-38, self.bounds.width, 38)
		self.textLabel.frame = self.blurBackgroundView.contentView.frame
		self.overlayView.frame = self.contentView.frame
	}
	
	
	
	public override var highlighted: Bool {
		didSet {
			if (self.highlighted) {
				self.overlayView.alpha = 0.3
			} else {
				self.overlayView.alpha = 0
			}
		}
	}
	
	
}
