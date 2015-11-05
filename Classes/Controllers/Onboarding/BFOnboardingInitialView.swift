//
//  BFOnboardingInitialView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-04.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation

class BFOnboardingInitialView : UIView
{
	
	internal let logoImageView = UIImageView()
	
	internal let tourLabel = UILabel()

	internal let arrorwImageView = UIImageView(image: UIImage(named: "forward-arrow-white"))


	
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		self.setup()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		self.setup()
	}


	func animate()
	{
		UIView.animateWithDuration(0.4, delay: 2, options: .CurveEaseIn, animations: { () -> Void in
			self.arrorwImageView.frame = CGRectMake((self.tourLabel.frame.origin.x+self.tourLabel.frame.size.width) + 15, self.tourLabel.frame.origin.y + 11, 8, 13)
		}) { (completed) -> Void in
			UIView.animateWithDuration(0.4, animations: { () -> Void in
				self.arrorwImageView.frame = CGRectMake((self.tourLabel.frame.origin.x+self.tourLabel.frame.size.width) + 5, self.tourLabel.frame.origin.y + 11, 8, 13)
			}) { (completed) -> Void in
				UIView.animateWithDuration(0.4, delay: 1, options: .CurveEaseIn, animations: { () -> Void in
					self.arrorwImageView.frame = CGRectMake((self.tourLabel.frame.origin.x+self.tourLabel.frame.size.width) + 15, self.tourLabel.frame.origin.y + 11, 8, 13)
				}) { (completed) -> Void in
					UIView.animateWithDuration(0.4, animations: { () -> Void in
						self.arrorwImageView.frame = CGRectMake((self.tourLabel.frame.origin.x+self.tourLabel.frame.size.width) + 5, self.tourLabel.frame.origin.y + 11, 8, 13)
					}) { (completed) -> Void in
						self.animate()
					}
				}
			}
		}
	}

	
	
	func setup()
	{
		self.logoImageView.image = UIImage(named: "logo-intro")
		self.addSubview(self.logoImageView)

		self.addSubview(self.arrorwImageView)

		self.tourLabel.font = UIFont(name: "Lato-Light", size: 26)
		self.tourLabel.textColor = UIColor.whiteColor()
		self.tourLabel.text = "Take the Tour"
		self.addSubview(self.tourLabel)
	}
	
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.logoImageView.frame = CGRectMake(self.frame.size.width/2 - 120, (self.frame.size.height/2-86)-60, 240, 56)

		self.tourLabel.frame = CGRectMake(self.logoImageView.frame.origin.x + 25, self.logoImageView.frame.origin.y + self.logoImageView.frame.size.height, 150, 30)

		self.arrorwImageView.frame = CGRectMake((self.tourLabel.frame.origin.x+self.tourLabel.frame.size.width) + 5, self.tourLabel.frame.origin.y + 12, 8, 13)
	}
	
}

