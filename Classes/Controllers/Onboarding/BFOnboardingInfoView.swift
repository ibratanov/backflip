//
//  BFOnboardingInfoView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-04.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation

public class BFOnboardingInfoView : UIView
{
	
	public var imageView = UIImageView(frame: CGRectZero)
	
	public var titleLabel = UILabel(frame: CGRectZero)

	public var detailLabel = UILabel(frame: CGRectZero)
	
	
	override public init(frame: CGRect)
	{
		super.init(frame: frame)
		
		self.setup()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		self.setup()
	}
	
	
	public func setup()
	{
		self.addSubview(self.imageView)


		self.titleLabel.font = UIFont(name: "Lato-Light", size: 28)
		self.titleLabel.textAlignment = .Center
		self.titleLabel.textColor = UIColor.whiteColor()
		self.titleLabel.frame = CGRectMake(30.5, 170, 259, 29)
		self.addSubview(self.titleLabel)


		self.detailLabel.font = UIFont(name: "Lato-Light", size: 20)
		self.detailLabel.textAlignment = .Center
		self.detailLabel.textColor = UIColor.whiteColor()
		self.detailLabel.adjustsFontSizeToFitWidth = false
		self.detailLabel.numberOfLines = 0
		self.detailLabel.lineBreakMode = .ByTruncatingTail
		self.addSubview(self.detailLabel)
	}
	
	
	override public func layoutSubviews()
	{
		super.layoutSubviews()

		self.titleLabel.frame = CGRectMake(30.5, (self.frame.height/2)-100, self.frame.width - 61, 29)
		self.detailLabel.frame = CGRectMake((self.frame.width/2)-125, self.titleLabel.frame.origin.y + 15, 250, 150)

		if (self.imageView.image != nil) {
			let imageSize = self.imageView.image!.size
			self.imageView.frame = CGRectMake((self.frame.width/2)-(imageSize.width/2), (self.titleLabel.frame.origin.y-imageSize.height)-10, imageSize.width, imageSize.height)
		}

	}
	
	
}
