//
//  BFExploreViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Parse
import Foundation


public class BFExploreViewController : UIViewController
{
	
	/**
	 * Scroll View, this contains both the `collectionView` and the `tableView`
	*/
	public var scrollView: UIScrollView!
	
	/**
	 * Featured View, used for "suggested events" section
	*/
	public var featuredView: BFFeaturedEventsView!
	
	/**
	 * Browse view, used for "browse" section
	*/
	public var browseView: BFBrowseEventsView!
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	public override func loadView()
	{
		super.loadView()
		
		// Exit out for auth ASAP
		self.handleAuthentication()
		
		// Logo
		self.navigationItem.titleView = UIImageView(image: UIImage(named: "backflip-logo-white"))
		
		// Tab bar delegate
		self.navigationController?.tabBarController?.delegate = BFTabBarControllerDelegate.sharedDelegate
		
		self.scrollView = UIScrollView(frame: CGRectZero)
		self.view.addSubview(self.scrollView)
		
		self.featuredView = BFFeaturedEventsView(frame: CGRectZero)
		self.browseView = BFBrowseEventsView(frame: CGRectZero)
		
		self.browseView.updateBlock = {
			self.browseView.frame = CGRectMake(0, self.featuredView.bounds.height, self.scrollView.frame.width, 45 + self.browseView.contentHeight())
			self.scrollView.contentSize = CGSizeMake(self.view.bounds.width, self.featuredView.frame.height + self.browseView.frame.height)
		}
			
		UIApplication.sharedApplication().statusBarHidden = false
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createButtonPressed:")
		
		self.scrollView.addSubview(self.featuredView)
		self.scrollView.addSubview(self.browseView)
	}

	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.handleAuthentication()
	}
	
	public override func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		
		self.scrollView.frame = self.view.bounds
		self.featuredView.frame = CGRectMake(0, 0, self.scrollView.frame.width, 220)
		self.browseView.frame = CGRectMake(0, self.featuredView.bounds.height, self.scrollView.frame.width, 45 + self.browseView.contentHeight())
		
		self.scrollView.contentSize = CGSizeMake(self.view.bounds.width, self.featuredView.frame.height + self.browseView.frame.height)
	}

	
	// ----------------------------------------
	//  MARK: - Touch events
	// ----------------------------------------
	
	public func createButtonPressed(sender: AnyObject?)
	{
		self.performSegueWithIdentifier("create-event", sender: sender)
	}
	
	
	// ----------------------------------------
	//  MARK: - Authentication
	// ----------------------------------------
	
	private func handleAuthentication() -> Void
	{
		//Handles displaying the onboarding screen if needed
		if (PFUser.currentUser() == nil || PFUser.currentUser()?.objectId == nil) {
			let onboardingViewController = BFOnboardingViewController()
			if let window = UIApplication.sharedApplication().windows.first {
				window.setRootViewController(onboardingViewController)
			}
		}
	}
}
