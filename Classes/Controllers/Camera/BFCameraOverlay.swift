//
//  BFCameraOverlay.swift
//  PreviewStandalone
//
//  Created by Jack Perry on 2015-10-07.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation

public class BFCameraOverlay : UIView
{
	/**
	 * Image Picker
	*/
	public weak var imagePicker : UIImagePickerController?


	/**
	 * Background Views
	*/
	internal var topBackgroundView : UIView?
	
	internal var bottomBackgroundView : UIView?
	
	
	/**
	 * Controls
	*/
	internal var cancelButton : UIButton?
	
	internal var flashButton : UIButton?
	
	internal var cameraSelectionButton : UIButton?
	
	internal var flashSelectionControl : UISegmentedControl?
	
	internal var cameraButton : UIButton?
	internal var cameraButtonBackground : UIImageView?
	
	internal var photoLibraryButton : UIButton?

	internal var eventLabel : UILabel?
	
	
	//------------------------------
	// MARK: Initializers
	//------------------------------
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		topBackgroundView = UIView(frame: CGRectZero)
		topBackgroundView?.backgroundColor = UIColor.blackColor()
		self.addSubview(topBackgroundView!)
		
		bottomBackgroundView = UIView(frame: CGRectZero)
		bottomBackgroundView?.backgroundColor = UIColor.blackColor()
		self.addSubview(bottomBackgroundView!)
		
		
		// Controls (Bottom)
		cancelButton = UIButton(type: .Custom)
		cancelButton?.setTitle("Cancel", forState: .Normal)
		cancelButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		cancelButton?.addTarget(self, action: "cancelButtonTouched", forControlEvents: .TouchUpInside)
		bottomBackgroundView?.addSubview(cancelButton!)


		eventLabel = UILabel(frame: CGRectZero)
		eventLabel?.textAlignment = .Center
		eventLabel?.textColor = UIColor.whiteColor()
		eventLabel?.font = UIFont.systemFontOfSize(14)
		self.addSubview(eventLabel!)
		
		cameraButtonBackground = UIImageView(image: UIImage(named: "CAMShutterButton"))
		bottomBackgroundView?.addSubview(cameraButtonBackground!)
		
		
		cameraButton = UIButton(type: .Custom)
		cameraButton?.layer.cornerRadius = 25
		cameraButton?.tintColor = UIColor.whiteColor()
		cameraButton?.backgroundColor = UIColor.whiteColor()
		cameraButton?.setImage((UIImage(named: "CAMShutterButtonSelected")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Highlighted)
		cameraButton?.imageView?.tintColor = UIColor.grayColor()
		cameraButton?.addTarget(self, action: "cameraButtonTouched", forControlEvents: .TouchUpInside)
		bottomBackgroundView?.addSubview(cameraButton!)

		photoLibraryButton = UIButton(type: .Custom)
		photoLibraryButton?.setTitle(" ", forState: .Normal)
		photoLibraryButton?.setImage((UIImage(named: "CAMPhotoLibrary")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Normal)
		photoLibraryButton?.imageView?.tintColor = UIColor.whiteColor()
		photoLibraryButton?.addTarget(self, action: "photoLibraryButtonTouched", forControlEvents: .TouchUpInside)
		bottomBackgroundView?.addSubview(photoLibraryButton!)
		
		
		// Control (Top)
		flashButton = UIButton(type: .Custom)
		flashButton?.setImage((UIImage(named: "CAMFlashButton")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Normal)
		flashButton?.addTarget(self, action: "flashButtonTouched", forControlEvents: .TouchUpInside)
		flashButton?.imageView?.tintColor = UIColor.whiteColor()
		topBackgroundView?.addSubview(flashButton!)
		
		cameraSelectionButton = UIButton(type: .Custom)
		cameraSelectionButton?.setImage((UIImage(named: "CAMFlipButton")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Normal)
		cameraSelectionButton?.addTarget(self, action: "cameraSelectionButtonTouched", forControlEvents: .TouchUpInside)
		cameraSelectionButton?.imageView?.tintColor = UIColor.whiteColor()
		topBackgroundView?.addSubview(cameraSelectionButton!)
		
		
		flashSelectionControl = UISegmentedControl(items: ["Auto", "On", "Off"])
		flashSelectionControl?.tintColor = UIColor.whiteColor()
		flashSelectionControl?.removeBorders()
		flashSelectionControl?.selectedSegmentIndex = 0
		if (imagePicker?.cameraFlashMode == .On) {
			flashSelectionControl?.selectedSegmentIndex = 1
		} else if (imagePicker?.cameraFlashMode == .Off) {
			flashSelectionControl?.selectedSegmentIndex = 2
		}
		flashSelectionControl?.alpha = 0
		flashSelectionControl?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:0.988,  green:0.780,  blue:0.231, alpha:1)], forState: .Selected)
		flashSelectionControl?.addTarget(self, action: "flashSelectionControlValueChanged:", forControlEvents: .ValueChanged)
		topBackgroundView?.addSubview(flashSelectionControl!)
		
	}
	
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	
	
	
	//------------------------------
	// MARK: Layout
	//------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		let bounds = self.bounds
		
		topBackgroundView?.frame = CGRectMake(0, 0, bounds.width, 44)
		
		flashButton?.frame = CGRectMake(10, (topBackgroundView!.frame.height/2) - 11, 22, 22)
		cameraSelectionButton?.frame = CGRectMake((topBackgroundView!.frame.width - 22) - 12, (topBackgroundView!.frame.height/2) - 11, 28, 21)
		flashSelectionControl?.frame = CGRectMake((topBackgroundView!.frame.width/2) - 100, (topBackgroundView!.frame.height/2) - 11, 200, 22)

		eventLabel?.frame = CGRectMake(10, bounds.height - 153, bottomBackgroundView!.frame.width - 20, 20)

		bottomBackgroundView?.frame = CGRectMake(0, bounds.height - 123, bounds.width, 123)
		
		cancelButton?.frame = CGRectMake(10, (bottomBackgroundView!.frame.height/2) - 10, 60, 20)
		cameraButtonBackground?.frame = CGRectMake((bottomBackgroundView!.frame.width/2) - 33, (bottomBackgroundView!.frame.height/2) - 33, 66, 66)
		cameraButton?.frame = CGRectMake((bottomBackgroundView!.frame.width/2) - 25, (bottomBackgroundView!.frame.height/2) - 25, 50, 50)
		photoLibraryButton?.frame = CGRectMake((topBackgroundView!.frame.width - 25) - 14, (bottomBackgroundView!.frame.height/2) - 12.5, 25, 25)
		bottomBackgroundView?.bringSubviewToFront(cameraButton!)
		
	}
	
	
	//------------------------------
	// MARK: Actions
	//------------------------------
	
	public func cancelButtonTouched()
	{
		let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController
		if (viewController != nil) {
			viewController?.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	public func flashButtonTouched()
	{
		if (flashSelectionControl?.alpha == 1.0) {
			
			// Hide the segmented control, show flip camera
			UIView.animateWithDuration(0.2, animations: { () -> Void in
				self.flashSelectionControl?.alpha = 0
				self.cameraSelectionButton?.alpha = 1
			})
			
		} else {
			
			UIView.animateWithDuration(0.2, animations: { () -> Void in
				self.flashSelectionControl?.alpha = 1
				self.cameraSelectionButton?.alpha = 0
			})
			
		}

	}
	
	
	public func cameraSelectionButtonTouched()
	{
		if (imagePicker?.cameraDevice == .Rear) {
			imagePicker?.cameraDevice = .Front
			if (UIImagePickerController.isFlashAvailableForCameraDevice(.Front) == false) {
				UIView.animateKeyframesWithDuration(0.2, delay: 0.1, options: .CalculationModeLinear, animations: { () -> Void in
					self.flashButton?.hidden = true
				}, completion: nil)
			}
		} else {
			imagePicker?.cameraDevice = .Rear
			if (UIImagePickerController.isFlashAvailableForCameraDevice(.Rear) == true) {
				UIView.animateKeyframesWithDuration(0.2, delay: 0.1, options: .CalculationModeLinear, animations: { () -> Void in
					self.flashButton?.hidden = false
				}, completion: nil)
			}
		}
		
	}
	
	
	public func flashSelectionControlValueChanged(control : UISegmentedControl)
	{
		var flashMode : UIImagePickerControllerCameraFlashMode = .Auto
		if (control.selectedSegmentIndex == 2) {
			flashMode = .Off
			flashButton?.setImage((UIImage(named: "CAMFlashButtonOff")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Normal)
			flashButton?.imageView?.tintColor = UIColor.whiteColor()
		} else {
			if (control.selectedSegmentIndex == 1) {
				flashMode = .On
			}
			
			flashButton?.setImage((UIImage(named: "CAMFlashButton")!.imageWithRenderingMode(.AlwaysTemplate)), forState: .Normal)
			flashButton?.imageView?.tintColor = UIColor.whiteColor()
		}
		
		imagePicker?.cameraFlashMode = flashMode
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			self.flashSelectionControl?.alpha = 0
			self.cameraSelectionButton?.alpha = 1
		})
	}
	
	
	public func cameraButtonTouched()
	{
		if (imagePicker != nil) {
			imagePicker?.takePicture()
		}
	}


	public func photoLibraryButtonTouched()
	{
		imagePicker?.dismissViewControllerAnimated(true, completion: { () -> Void in
			BFCameraController.sharedController.presentPhotoLibrary()
		})
	}
	
}






extension UISegmentedControl
{
	
	func removeBorders()
	{
		setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Normal, barMetrics: .Default)
		setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Selected, barMetrics: .Default)
		setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
	}
	
	// create a 1x1 image with this color
	private func imageWithColor(color: UIColor) -> UIImage
	{
		let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextFillRect(context, rect);
		let image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image
	}
}