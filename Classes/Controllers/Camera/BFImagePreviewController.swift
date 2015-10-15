//
//  BFImagePreviewController.swift
//  PreviewStandalone
//
//  Created by Jack Perry on 2015-10-07.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation



@objc public protocol BFImagePreviewDelegate
{

	optional func imagePreviewDidCancel(imagePreview: BFImagePreviewController)
	
	optional func imagePreviewDidSelectUploadButton(imagePreview: BFImagePreviewController, button: UIButton?, image: UIImage?, comment: String?)

}



public class BFImagePreviewController : UIViewController, UITextViewDelegate
{

	/**
	 * Delegate
	*/
	public var delegate : BFImagePreviewDelegate?


	/**
	 * Public properties
	*/
	public var image : UIImage?



	/**
	 * Controls
	*/
	public var imageView : UIImageView?
	
	private var textView : UITextView?
	
	private var uploadButton : UIButton?



	//------------------------------------
	// MARK: Initializers
	//------------------------------------

	required public init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	

	//------------------------------------
	// MARK: View loading
	//------------------------------------
	
	override public func loadView()
	{
		super.loadView()
		
		// Image View
		imageView = UIImageView()
		imageView?.image = self.image
		imageView?.contentMode = .ScaleToFill
		self.view.addSubview(imageView!)


		// Upload Button
		uploadButton = UIButton(type: .Custom)
		uploadButton?.backgroundColor = UIColor(red:0.082,  green:0.596,  blue:0.541, alpha:1)
		uploadButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		uploadButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
		uploadButton?.setTitle("Upload", forState: .Normal)
		uploadButton?.layer.cornerRadius = 8
		uploadButton?.addTarget(self, action: "uploadButtonTouched:", forControlEvents: .TouchUpInside)
		self.view.addSubview(uploadButton!)

		
		// Text View
		textView = UITextView()
		textView?.delegate = self
		textView?.text = "Add comment.."
		textView?.textColor = UIColor.lightGrayColor()
		textView?.font = UIFont.systemFontOfSize(18)
		textView?.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
		textView?.returnKeyType = .Done
		textView?.keyboardDismissMode = .Interactive
		self.view.addSubview(textView!)

	}
	
	
	override public func viewDidLoad()
	{
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		view.layer.cornerRadius = 8.0
		view.layer.shadowColor = UIColor.blackColor().CGColor
		view.layer.shadowOffset = CGSizeMake(0, 0)
		view.layer.shadowRadius = 8
		view.layer.shadowOpacity = 0.5
	}
	


	//------------------------------------
	// MARK: Subview Layout
	//------------------------------------

	override public func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()

		imageView?.frame = CGRectMake(5, 5, self.view.frame.width - 10, 200)

		// ImageView mask
		let maskedCorners = UIRectCorner.TopLeft.union(UIRectCorner.TopRight)
		let maskedPath = UIBezierPath(roundedRect: imageView!.bounds, byRoundingCorners: maskedCorners, cornerRadii: CGSizeMake(8, 8))
		let maskedLayer = CAShapeLayer()
		maskedLayer.frame = self.view.bounds
		maskedLayer.path = maskedPath.CGPath
		imageView?.layer.mask = maskedLayer


		textView?.frame = CGRectMake(5, (imageView!.frame.origin.x * 2) + imageView!.frame.height, self.view.frame.width - 10, 100)

		uploadButton?.frame = CGRectMake(5, (self.view.frame.height - 50) - 5, self.view.frame.width - 10, 50)
	}



	//------------------------------------
	// MARK: Touch events
	//------------------------------------

	public func uploadButtonTouched(sender: AnyObject?)
	{
		#if DEBUG
			print("🚀 uploadButtonTouched: \(sender)")
		#endif

		var comment = textView?.text
		if (comment == "Add comment.."){
			comment = nil
		}
		
		delegate?.imagePreviewDidSelectUploadButton?(self, button: uploadButton, image: self.image, comment: comment)

		self.dismissViewControllerAnimated(true, completion: nil)
	}

	public func cancelButtonTouched(sender: AnyObject?)
	{
		#if DEBUG
			print("🚧 cancelButtonTouched: \(sender)")
		#endif

		delegate?.imagePreviewDidCancel?(self)

		self.dismissViewControllerAnimated(true, completion: nil)
	}



	//------------------------------------
	// MARK: Text View Delegate
	//------------------------------------

	public func textViewDidEndEditing(textView: UITextView)
	{
		if (textView.text == "") {
			textView.text = "Add comment.."
			textView.textColor = UIColor.lightGrayColor()
		}

		textView.resignFirstResponder()
	}

	public func textViewDidBeginEditing(textView: UITextView)
	{
		if (textView.text == "Add comment..") {
			textView.text = ""
			textView.textColor = UIColor.blackColor()
		}

		textView.becomeFirstResponder()
	}


	public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
	{
		if (text == "\n") {
			textView.resignFirstResponder()
			return false
		}

		// Allow deletion when we're sitting at 26 chars..
		if (text.characters.count < 1 && textView.text!.characters.count == 26) {
			return true
		}

		return textView.text!.characters.count <= 25
	}

}




/**
 * !! IMPORTANT !!
 *
 * Everything below this line has nothing todo with image previewing
 * The below code is only used for handling the custom presentation style
 * You'd very rarely, if at all have issues with the code below. If LLDB 
 * raises an exception here, check inside loadView, and viewWillAppear: 
 * above
*/


class BFImagePreviewTransitionDelegate : NSObject, UIViewControllerTransitioningDelegate
{
	
	func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
	{
		return BFImagePreviewPresentationController(presentedViewController: presented, presentingViewController: presenting)
	}
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController)-> UIViewControllerAnimatedTransitioning?
	{
		return BFImagePreviewControllerAnimator()
	}
	
}



class BFImagePreviewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning
{
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
	{
		return 0.8
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning)
	{
		if let presentedView = transitionContext.viewForKey(UITransitionContextToViewKey) {
			let centre = presentedView.center
			presentedView.center = CGPointMake(centre.x, -presentedView.bounds.size.height)
			
			transitionContext.containerView()!.addSubview(presentedView)
			
			UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10.0, options: [], animations: {
				presentedView.center = centre
			}, completion: { _ in
				transitionContext.completeTransition(true)
			})
		}
	}
	
}


class BFImagePreviewPresentationController : UIPresentationController
{
	
	let dimmingView = UIView()
	
	override init(presentedViewController: UIViewController, presentingViewController: UIViewController)
	{
		super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
		dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)

		let tapGesture = UITapGestureRecognizer(target: self, action: "dimmingViewTouched:")
		tapGesture.numberOfTapsRequired = 1
		dimmingView.addGestureRecognizer(tapGesture)

	}
	
	override func presentationTransitionWillBegin()
	{
		dimmingView.frame = containerView!.bounds
		dimmingView.alpha = 0.0
		containerView!.insertSubview(dimmingView, atIndex: 0)
		
		presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ context in
			self.dimmingView.alpha = 1.0
		}, completion: nil)
	}
	
	override func dismissalTransitionWillBegin()
	{
		presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ context in
			self.dimmingView.alpha = 0.0
		}, completion: { context in
			self.dimmingView.removeFromSuperview()
		})
	}
	
	override func frameOfPresentedViewInContainerView() -> CGRect
	{
		var insertRect = containerView!.bounds.insetBy(dx: 20, dy: 60)
		insertRect.size.height = 370
		return insertRect
	}
	
	override func containerViewWillLayoutSubviews()
	{
		dimmingView.frame = containerView!.bounds
		presentedView()!.frame = frameOfPresentedViewInContainerView()
	}


	func dimmingViewTouched(sender : AnyObject?)
	{
		let imagePreviewController = presentedViewController as! BFImagePreviewController
		imagePreviewController.cancelButtonTouched(nil)
	}

}

