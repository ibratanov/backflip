//
//  BFFeaturedEventsView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Kingfisher

public class BFFeaturedEventsView : UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate
{
	
	/**
	 * Featured Events, array of `Event` objects
	*/
	public var events: [Event] = []
	
	
	/**
	 * Collection View, used for "suggested events" section
	*/
	private var collectionView: UICollectionView!
	
	/**
	 * View header/title label
	*/
	private var titleLabel: UILabel!
	
	/**
	 * Page Control
	*/
	private var pageControl: UIPageControl!
	
	/**
	 * 1 pixel line at the bottom of the view
	*/
	private var lineView: UIView!
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		self.loadView()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		self.loadView()
	}
	
	
	private func loadView()
	{
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionViewLayout.itemSize = CGSizeMake(112, 154)
		collectionViewLayout.minimumInteritemSpacing = 6.5
		collectionViewLayout.scrollDirection = .Horizontal
		
		self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.backgroundColor = UIColor.whiteColor()
		self.collectionView.pagingEnabled = true
		self.collectionView.showsHorizontalScrollIndicator = false
		self.addSubview(self.collectionView)
		
		self.collectionView.registerClass(BFFeaturedEventCell.self, forCellWithReuseIdentifier: BFFeaturedEventCell.reuseIdentifier)
		self.collectionView.registerClass(BFFeaturedBlankCell.self, forCellWithReuseIdentifier: BFFeaturedBlankCell.reuseIdentifier)
		
		self.titleLabel = UILabel(frame: CGRectZero)
		if #available(iOS 8.2, *) {
		    self.titleLabel.font = UIFont.systemFontOfSize(10, weight: UIFontWeightSemibold)
		} else {
			self.titleLabel.font = UIFont.systemFontOfSize(10)
		}
		
		let text = NSLocalizedString("title.discover.suggested-events", comment: "SUGGESTED EVENTS")
		let attributedText = NSMutableAttributedString(string: text)
		attributedText.addAttribute(NSKernAttributeName, value: 3.0, range: NSMakeRange(0, text.characters.count))
		
		self.titleLabel.attributedText = attributedText
		self.titleLabel.textColor = UIColor.grayColor()
		self.addSubview(self.titleLabel)
		
		self.pageControl = UIPageControl(frame: CGRectZero)
		self.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
		self.pageControl.currentPageIndicatorTintColor = UIColor.grayColor()
		self.addSubview(self.pageControl)
		
		self.lineView = UIView(frame: CGRectZero)
		self.lineView.backgroundColor = UIColor(red:0.851,  green:0.851,  blue:0.851, alpha:1)
		self.addSubview(self.lineView)
		
		self.loadEvents(false)
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.collectionView.frame = CGRectMake(7, 45, self.bounds.width-14, 154)
		self.titleLabel.frame = CGRectMake(7, 18, self.bounds.width-14, 12)
		self.pageControl.frame = CGRectMake(7, (self.collectionView.frame.origin.y + self.collectionView.frame.height) + 2.5, self.bounds.width-14, 10)
		self.lineView.frame = CGRectMake(0, self.bounds.height - 0.5, self.bounds.width, 0.5)
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Collection View (Data source)
	// ----------------------------------------
	@available(iOS 6.0, *)
	public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		let numberOfItems = self.events.count
		
		self.pageControl.numberOfPages = 1 * Int(ceil(Double(numberOfItems) / 3.0)) // Round up to nearist 1
		return (self.pageControl.numberOfPages * 3)
	}
	
	// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
	@available(iOS 6.0, *)
	public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		var cell: UICollectionViewCell!
		if (indexPath.row < self.events.count) {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(BFFeaturedEventCell.reuseIdentifier, forIndexPath: indexPath)
			
			let event = self.events[indexPath.row]
			(cell as! BFFeaturedEventCell).textLabel.text = event.name
			if (event.featureImage != nil) {
				let imageUrl = NSURL(string: event.featureImage!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))
				(cell as! BFFeaturedEventCell).imageView.kf_setImageWithURL(imageUrl!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))])
			}
		} else {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(BFFeaturedBlankCell.reuseIdentifier, forIndexPath: indexPath)
		}
		
		
		return cell
	}

	@available(iOS 6.0, *)
	public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row < self.events.count) {
			let viewController = BFPreviewViewController()
			viewController.event = self.events[indexPath.row]
			let modalNavigationController = LGSemiModalNavViewController(rootViewController: viewController)
			modalNavigationController.view.frame = CGRectMake(0, 0, self.bounds.width, 472)
	
			modalNavigationController.backgroundShadeColor = UIColor.blackColor()
			modalNavigationController.animationSpeed = 0.35
			modalNavigationController.backgroundShadeAlpha = 0.4
			modalNavigationController.tapDismissEnabled = true
			modalNavigationController.scaleTransform = CGAffineTransformMakeScale(0.94, 0.94)
		
			let window : UIWindow? = UIApplication.sharedApplication().windows.first!
			window?.rootViewController!.presentViewController(modalNavigationController, animated: true, completion: nil)
		}
	}
	
	
	// ----------------------------------------
	//  MARK: - Scroll View (Delegate)
	// ----------------------------------------
	
	public func scrollViewDidScroll(scrollView: UIScrollView)
	{
		let pageWidth = scrollView.frame.size.width
		let pageIndex = Int(floor((scrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
		
		self.pageControl.currentPage = pageIndex
	}
	
	
	// ----------------------------------------
	//  MARK: - Data
	// ----------------------------------------
	
	private func loadEvents(animated: Bool)
	{
		self.events.removeAll()
		
		let predicate = NSPredicate(format: "%K =< %@ AND %K >= %@ AND %K == %@", argumentArray: ["startTime", NSDate(), "endTime", NSDate(), "enabled", NSNumber(integer: 1)])
		let features = EventFeature.MR_findAllSortedBy("priority", ascending: false, withPredicate: predicate) as! [EventFeature]
		if (features.count < 1) {
			return
		}
		
		for feature in features {
			if (feature.sticky?.boolValue == true) {
				self.events.append(feature.event!)
				continue;
			}
			
			var attended: Bool = false
			let attendees = feature.event?.attendees?.allObjects as! [Attendance]
			for attendee in attendees {
				if (PFUser.currentUser() != nil && attendee.attendeeId == PFUser.currentUser()?.objectId) {
					attended = true
				}
			}
			
			if (attended == false) {
				self.events.append(feature.event!)
			}
		}

		self.collectionView.reloadData()
	}

}
