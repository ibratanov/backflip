//
//  ViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-04.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import DigitsKit

class BFOnboardingViewController : UIViewController, UIScrollViewDelegate
{
	// Backgrounds
	internal var gradientView : BFGradientView?
	internal var animatedView : BFOnboardingImageView?
	
	
	// Buttons
	internal var facebookButton : UIButton = UIButton(type: .Custom)
	internal var digitsButton : UIButton = UIButton(type: .Custom)
	
	internal var pageControl : UIPageControl = UIPageControl()
	
	internal var scrollView : UIScrollView = UIScrollView()
	
	// Page cache
	internal var cachedPages : [AnyObject?] = []
	
	// Content
	internal var images : [String] = ["made-easy-icon", "how-it-works-icon", "why-trust-icon", "start-stashing-icon"]
	internal var titles : [String] = ["Everyone Can Invest", "It's Easy To Get Started", "Stash Has Your Back", "Start Saving", ""]
	internal var descriptions : [String] = [
		"Investing use to be complicated, with high minimums and fees, We've made it simple and affordable",
		"Pick an investment tied to somethingthing you believe, like or want. Invest as little as $5. And Stash will guide you from there.",
		"Rest Easy. Your data is secure. You can withdraw money at anytime. And our pricing is simple: We charge $1 a month. Once your account reaches $5,000, we change 0.25% of your balance per year.",
		"Start with as little as $5 and have your money work for you"
	]
	
	
	
	// ----------------------------------
	//  MARK: - Paging Scroll View
	// ----------------------------------
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.configureViews()
	}

	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)

		let page = self.cachedPages[0] as! BFOnboardingInitialView
		page.animate()

		self.animatedView?.animationLoop()
	}

	
	func configureViews()
	{
		self.view.addSubview(scrollView)
		
		self.view.addSubview(facebookButton)
		self.view.addSubview(digitsButton)
		
		self.view.addSubview(pageControl)
		
		self.setupScrollView()
		
		self.setupButtons()
		self.setupPageControl()
		self.configureBackgrounds()
		
		self.loadVisiblePages()
	}
	
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle
	{
		return .LightContent
	}
	
	
	internal func setupScrollView()
	{
		self.scrollView.delegate = self
		self.scrollView.pagingEnabled = true
		self.scrollView.frame = self.view.bounds
		self.scrollView.showsHorizontalScrollIndicator = false
		
		let pageCount = 1 + images.count
		let pageSize = scrollView.frame.size
		
		for _ in 0..<pageCount {
			self.cachedPages.append(nil)
		}
		
		scrollView.contentSize = CGSize(width: pageSize.width * CGFloat(pageCount), height: pageSize.height)
		scrollView.userInteractionEnabled = true

		let tapGesture = UITapGestureRecognizer(target: self, action: "nextSlide:")
		tapGesture.numberOfTapsRequired = 1
		scrollView.addGestureRecognizer(tapGesture)
	}
	
	
	
	// ----------------------------------
	//  MARK: - Buttons
	// ----------------------------------
	
	internal func setupButtons()
	{
		digitsButton.backgroundColor = UIColor(red:0,  green:0.765,  blue:0.263, alpha:1)
		digitsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		digitsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
		digitsButton.layer.cornerRadius = 25
		digitsButton.titleLabel?.font =  UIFont(name: "Lato-Light", size: 20)
		digitsButton.setTitle("Log in via SMS", forState: .Normal)
		digitsButton.addTarget(self, action: "digitsLogin:", forControlEvents: .TouchUpInside)
		digitsButton.frame = CGRectMake(10, (self.view.bounds.height - 60) - 50, self.view.bounds.width - 20, 50)
	
		facebookButton.backgroundColor = UIColor(red:0.231,  green:0.349,  blue:0.596, alpha:1)
		facebookButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		facebookButton.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
		facebookButton.layer.cornerRadius = 25
		facebookButton.titleLabel?.font =  UIFont(name: "Lato-Light", size: 20)
		facebookButton.setTitle("Log in via Facebook", forState: .Normal)
		facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: .TouchUpInside)
		facebookButton.frame = CGRectMake(10, (self.digitsButton.frame.origin.y - 10) - 50, self.view.bounds.width - 20, 50)
	}
	
	
	// ----------------------------------
	//  MARK: - Backgrounds
	// ----------------------------------
	
	internal func configureBackgrounds()
	{
		self.gradientView = BFGradientView.init(frame: self.view.frame)
		self.gradientView?.alpha = 0
		self.view.addSubview(self.gradientView!)
		self.view.sendSubviewToBack(self.gradientView!)
		
		self.animatedView = BFOnboardingImageView.init(frame: self.view.frame)
		self.view.addSubview(self.animatedView!)
		self.view.sendSubviewToBack(self.animatedView!)
	}

	
	// ----------------------------------
	//  MARK: - Page Control
	// ----------------------------------
	
	internal func setupPageControl()
	{
		self.pageControl.currentPage = 0
		self.pageControl.numberOfPages = 1 + images.count
		self.pageControl.frame = CGRectMake((self.view.bounds.width/2) - 60, facebookButton.frame.origin.y - 40, 120, 20)
	}
	
	internal func loadPage(pageIndex index: Int)
	{
		if (index < 0 || index >= (1+images.count)) {
			return // It's outside the page range..
		}
		
		if cachedPages[index] != nil {
			// Nothing todo, page is cached
		} else {
			
			var frame = scrollView.bounds
			frame .origin.x = frame.size.width * CGFloat(index)
			frame.origin.y = 0
			
			if (index == 0) {
				let page = BFOnboardingInitialView.init(frame: frame)
				self.scrollView.addSubview(page)
				
				self.cachedPages[index] = page
			} else {
				let page = BFOnboardingInfoView()
				page.imageView.image = UIImage(named: images[(index-1)])
				page.titleLabel.text = titles[(index-1)]
				page.detailLabel.text = descriptions[(index-1)]

				page.frame = frame
				self.scrollView.addSubview(page)
				
				self.cachedPages[index] = page
			}
			
		}
		
	}
	
	internal func purgePage(pageIndex index: Int)
	{
		if (index < 0 || index >= (1+images.count)) {
			return // It's outside the page range..
		}
		
		let page = cachedPages[index]
		page?.removeFromSuperview()
		cachedPages[index] = nil
	}
	
	internal func loadVisiblePages()
	{
		let pageWidth = scrollView.frame.size.width
		let pageIndex = Int(floor((scrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
		
		self.pageControl.currentPage = pageIndex
		
		let firstPage = pageIndex - 1
		let lastPage = pageIndex + 1
		
		// Purge anything before the first page
		for var index = 0; index < firstPage; ++index {
			self.purgePage(pageIndex: index)
		}
		
		// Load pages in our visible range
		for var index = firstPage; index <= lastPage; ++index {
			self.loadPage(pageIndex: index)
		}
		
		// Purge anything after the last page
		for var index = lastPage+1; index < images.count; ++index {
			self.purgePage(pageIndex: index)
		}
	}
	
	
	
	// ----------------------------------
	//  MARK: - Scroll View Delegate
	// ----------------------------------
	
	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		self.loadVisiblePages()
		
		if (scrollView.contentOffset.x > 0) {
			if (scrollView.contentOffset.x <= 120) {
				self.gradientView?.alpha = (scrollView.contentOffset.x - 40)/2 * (1.0 / 35)
			}
		}
		
		if (scrollView.contentOffset.x > 120) {
			self.gradientView?.alpha = 1
		}
	}

	
	// ------------------------------------
	//  MARK: - Actions
	// ------------------------------------
	
	func nextSlide(sender: AnyObject?)
	{
		let pageWidth = scrollView.frame.size.width
		let pageIndex = Int(floor((scrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
		if ((pageIndex + 1) >= (1+images.count)) {
			return
		}

		let nextFrameOriginX = scrollView.bounds.size.width * CGFloat(pageIndex + 1)

		self.scrollView.scrollRectToVisible(CGRectMake(nextFrameOriginX, 0, scrollView.bounds.size.width, scrollView.bounds.size.height), animated: true)
	}
	
	
	func digitsLogin(sender: AnyObject?)
	{
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
		
		// Network reachability checking
		guard Reachability.validNetworkConnection() else {
			return Reachability.presentUnavailableAlert()
		}
		

		
		// Initiate digits session
		let digits = Digits.sharedInstance()
		let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
		configuration.appearance = DGTAppearance()
		configuration.appearance.backgroundColor = UIColor.whiteColor()
		configuration.appearance.accentColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
		configuration.appearance.logoImage = UIImage(named: "backflip-logo-white")
		
		configuration.appearance.bodyFont = UIFont(name: "Lato-Light", size: 16)
		configuration.appearance.headerFont = UIFont(name: "Lato-Light", size: 18)
		configuration.appearance.labelFont = UIFont(name: "Lato-Bold", size: 16)
		
		// Start the authentication flow with the custom appearance. Nil parameters for default values.
		digits.authenticateWithViewController(nil, configuration:configuration) { (session, error) in
			
			UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
			
			BFParseManager.sharedManager.login(session, facebookResult: nil, uponCompletion: { (completed, error) -> Void in
				
				if (completed == true) {
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				
				print("Login completed = \(completed)")
				print("Login error = \(error)")
				
			})
			
		}
		
	}
	
	
	func facebookLogin(sender: AnyObject?)
	{
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)

		FBSDKLoginManager.renewSystemCredentials { (results, error) -> Void in
			
			let login = FBSDKLoginManager()
			// When maddie decides: "user_hometown"
			login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, error) -> Void in
				if (error != nil) {
					print("Facebook login error")
					print(error)
				} else if (result.isCancelled == true) {
					print("Canceled")
				} else {
					print("Login success")
					
					
					BFParseManager.sharedManager.login(nil, facebookResult: result, uponCompletion: { (completed, error) -> Void in
						
						if (completed == true) {
							self.dismissViewControllerAnimated(true, completion: nil)
						}
						
						
						print("Login completed = \(completed)")
						print("Login error = \(error)")
						
					})
					
				}
				
			}
			
		}
	}
	

	// ------------------------------------
	//  MARK: - Memory Management
	// ------------------------------------
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}


}

