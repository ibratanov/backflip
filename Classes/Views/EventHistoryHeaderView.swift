//
//  EventHistoryHeaderView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-23.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation


class EventHistoryHeaderView : UICollectionReusableView
{
	
	var eventTitle : UILabel?
	var eventLocation : UILabel?
	var eventDate : UILabel?
	
	
	internal var blurEffectView : UIVisualEffectView?
	
	
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		setup()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		setup()
	}
	
	
	func setup()
	{
		let blurEffect = UIBlurEffect(style: .Light)
		blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView?.frame = self.bounds
		self.addSubview(blurEffectView!)

		self.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
		
		// Event Title
		self.eventTitle = UILabel(frame: CGRectZero)
		self.eventTitle?.font = UIFont.systemFontOfSize(20.0)
		blurEffectView?.contentView.addSubview(self.eventTitle!)
		
		
		// Event Location
		self.eventLocation = UILabel(frame: CGRectZero)
		self.eventLocation?.font = UIFont.systemFontOfSize(11.0)
		blurEffectView?.contentView.addSubview(self.eventLocation!)
		
		// Event Date
		self.eventDate = UILabel(frame: CGRectZero)
		self.eventDate?.font = UIFont.systemFontOfSize(11.0)
		self.eventDate?.textAlignment = .Right
		blurEffectView?.contentView.addSubview(self.eventDate!)
	}
	
	
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		blurEffectView?.frame = self.bounds
		
		// Event Title
		self.eventTitle?.frame = CGRectMake(5.0, 5.0, self.bounds.size.width-10, 20.0)
	
		
		// Event Location
		self.eventLocation?.frame = CGRectMake(5.0, 23.0, self.bounds.size.width-10, 20.0)
		
		
		// Event Date
		self.eventDate?.frame = CGRectMake(5.0, 23.0, self.bounds.size.width-10, 20.0)

	}
	
	
	
	override func prepareForReuse()
	{
		super.prepareForReuse()
		
		self.eventDate?.text = ""
		self.eventTitle?.text = ""
		self.eventLocation?.text = ""
	}
	
}