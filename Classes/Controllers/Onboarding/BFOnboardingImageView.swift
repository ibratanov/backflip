//
//  BFOnboardingImageView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-04.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation


class BFOnboardingImageView : UIView
{

	internal var imageView : UIImageView?
	internal var altImageView : UIImageView?
	
	internal var currentIndex = 0
	internal var images = ["background-1", "login-background", "Scene-4"]
	
	
	
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
	
	
	
	// --------------------------------
	//  MARK: - Setup
	// ---------------------------------
	
	func setup()
	{
		self.imageView = UIImageView(frame: CGRectMake(0, -15, self.frame.width, self.frame.height+15))
		self.imageView?.image = UIImage(named: images[currentIndex])
		self.imageView?.alpha = 1

		self.altImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.width, self.frame.height+15))
		self.altImageView?.alpha = 0

		self.addSubview(self.imageView!)
		self.addSubview(self.altImageView!)
	}
	
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.imageView?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height+15)
	}
	


	func animationLoop()
	{

		if (self.imageView?.alpha == 0) {
			self.animateToAltImageView()
		} else {
			self.animateToImageView()
		}


	}


	func animateToImageView()
	{
		UIView.animateWithDuration(4, delay: 1, options: .CurveEaseIn, animations: { () -> Void in

			self.imageView?.frame = CGRectMake(0, -15, self.frame.width, self.frame.height+15)

		}) { (completed) -> Void in

			self.currentIndex++
			if (self.currentIndex > (self.images.count-1)) {
				self.currentIndex = 0
			}


			self.altImageView?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height+15)
			self.altImageView?.image = UIImage(named: self.images[self.currentIndex])

			UIView.animateWithDuration(2, delay: 0, options: .TransitionCrossDissolve, animations: { () -> Void in
				self.imageView?.alpha = 0
				self.altImageView?.alpha = 1
			}, completion: { (completed) -> Void in
				self.animationLoop()
			})

		}
	}


	func animateToAltImageView()
	{
		UIView.animateWithDuration(4, delay: 1, options: .CurveEaseIn, animations: { () -> Void in

			self.altImageView?.frame = CGRectMake(0, -15, self.frame.width, self.frame.height+15)

		}) { (completed) -> Void in

				self.currentIndex++
				if (self.currentIndex > (self.images.count-1)) {
					self.currentIndex = 0
				}


				self.imageView?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height+15)
				self.imageView?.image = UIImage(named: self.images[self.currentIndex])

				UIView.animateWithDuration(2, delay: 0, options: .TransitionCrossDissolve, animations: { () -> Void in
					self.imageView?.alpha = 1
					self.altImageView?.alpha = 0
				}, completion: { (completed) -> Void in
						self.animationLoop()
				})
				
		}
	}

	
}

