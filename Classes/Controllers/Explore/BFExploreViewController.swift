//
//  BFExploreViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
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
		
		// Logo
		self.navigationItem.titleView = UIImageView(image: UIImage(named: "backflip-logo-white"))
		
		self.scrollView = UIScrollView(frame: CGRectZero)
		self.view.addSubview(self.scrollView)
		
		self.featuredView = BFFeaturedEventsView(frame: CGRectZero)
		self.browseView = BFBrowseEventsView(frame: CGRectZero)
		
		self.browseView.updateBlock = {
			print("We should update the frame now..")
			
			self.browseView.frame = CGRectMake(0, self.featuredView.bounds.height, self.scrollView.frame.width, 45 + self.browseView.contentHeight())
			self.scrollView.contentSize = CGSizeMake(self.view.bounds.width, self.featuredView.frame.height + self.browseView.frame.height)
		}
			
		UIApplication.sharedApplication().statusBarHidden = false
		
		self.scrollView.addSubview(self.featuredView)
		self.scrollView.addSubview(self.browseView)
	}

	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func viewWillLayoutSubviews()
	{
		self.scrollView.frame = self.view.bounds
		self.featuredView.frame = CGRectMake(0, 0, self.scrollView.frame.width, 220)
		self.browseView.frame = CGRectMake(0, self.featuredView.bounds.height, self.scrollView.frame.width, 45 + self.browseView.contentHeight())
		
		self.scrollView.contentSize = CGSizeMake(self.view.bounds.width, self.featuredView.frame.height + self.browseView.frame.height)
	}

	
	
}
