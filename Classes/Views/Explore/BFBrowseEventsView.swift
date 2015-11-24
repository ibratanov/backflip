//
//  BFBrowseEventsView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Kingfisher
import INTULocationManager

public class BFBrowseEventsView : UIView, UITableViewDataSource, UITableViewDelegate
{
	
	/**
	 * Events, array of `Event` objects
	*/
	public var events: [Event] = []
	
	/**
	 * Block called when `tableView` has been reloaded / hieght changed
	*/
	public typealias BFBrowseContentUpdateBlock = () -> Void
	
	public var updateBlock : BFBrowseContentUpdateBlock?
	
	/**
	 * Table View
	*/
	private var tableView: UITableView!

	/**
	 * Title label
	*/
	private var titleLabel: UILabel!
	
	
	
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
		self.tableView = UITableView(frame: CGRectZero, style: .Plain)
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.scrollEnabled = false
		self.addSubview(self.tableView)
		
		self.tableView.registerClass(BFBrowseEventCell.self, forCellReuseIdentifier: BFBrowseEventCell.reuseIdentifier)
		
		self.titleLabel = UILabel(frame: CGRectZero)
		if #available(iOS 8.2, *) {
		    self.titleLabel.font = UIFont.systemFontOfSize(10, weight: UIFontWeightSemibold)
		} else {
		    self.titleLabel.font = UIFont.systemFontOfSize(10)
		}
		
		let text = NSLocalizedString("title.discover.browse", comment: "BROWSE")
		let attributedText = NSMutableAttributedString(string: text)
		attributedText.addAttribute(NSKernAttributeName, value: 3.0, range: NSMakeRange(0, text.characters.count))
		
		self.titleLabel.attributedText = attributedText
		self.titleLabel.textColor = UIColor.grayColor()
		self.addSubview(self.titleLabel)
		
		self.loadEvents(false)
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Layout
	// ----------------------------------------
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.titleLabel.frame = CGRectMake(7, 18, self.bounds.width-14, 12)
		self.tableView.frame = CGRectMake(0, 45, self.bounds.width, self.contentHeight())

	}

	public func contentHeight() -> CGFloat
	{
		return CGFloat(self.events.count * Int(BFBrowseEventCell.contentHight))
	}
	
	
	
	
	// ----------------------------------------
	//  MARK: - Table View (Data Source)
	// ----------------------------------------
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		print("\(__FUNCTION__) = \(self.events.count)")
		return self.events.count
	}
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(BFBrowseEventCell.reuseIdentifier, forIndexPath: indexPath) as! BFBrowseEventCell
		
		let event = self.events[indexPath.row]
		cell.textLabel?.text = event.name
		cell.detailTextLabel?.text = event.venue
		cell.rightDetailLabel.text = event.startTime?.timeTogo
		
		return cell
	}

	
	

	// ----------------------------------------
	//  MARK: - Table View (Delegate)
	// ----------------------------------------
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return BFBrowseEventCell.contentHight
	}

	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
	{
		guard let cell = cell as? BFBrowseEventCell else { fatalError("Expected to display a `BFBrowseEventCell`.") }
		
		let event = self.events[indexPath.row]
		
		if let image = event.previewImage {
			let imageUrl = NSURL(string: image.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))
			cell.backgroundImageView?.kf_setImageWithURL(imageUrl!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))])
		}
		
	}
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
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
	
	
	
	// ----------------------------------------
	//  MARK: - Data
	// ----------------------------------------
	
	public func loadEvents(animated: Bool)
	{
		self.events.removeAll()
	
		
		INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.Block, timeout: 15.0, delayUntilAuthorized: true) { (location, accuracy, status) -> Void in
			
			if (status == .Success) {
				self.loadEvents(true, location: location)
			} else if (status == .TimedOut) {
				print("Location error :(, timed out")
			} else {
				print("General location error")
			}
			
		}
		
	}
	
	
	private func loadEvents(animated: Bool = true, location: CLLocation)
	{
		let config = PFConfig.currentConfig()
		let _events = Event.MR_findAll() as! [Event]
		let nearbyEvents : NSMutableArray = NSMutableArray()
		
		let radius = config["nearby_events_radius"] != nil ? config["nearby_events_radius"]! as! NSNumber : 10 // Default: 10km (It's really in meters here 'cause of legacy, turns to Kms below)
		let region : CLCircularRegion = CLCircularRegion(center: location.coordinate, radius: (radius.doubleValue * 1000), identifier: "nearby-events-region")
		
		// Filter by event location and attancance
		for event : Event in _events {
			if (event.geoLocation != nil && event.enabled != nil && Bool(event.enabled!) == true) {
				
				if (event.endTime != nil && event.endTime?.isGreaterThanDate(NSDate()) == true) {
				
					let coordinate = CLLocationCoordinate2D(latitude: event.geoLocation!.latitude!.doubleValue, longitude: event.geoLocation!.longitude!.doubleValue)
					if (region.containsCoordinate(coordinate)) {
					
						var attended = false
						let attendees = event.attendees!.allObjects as! [Attendance]
						for attendee : Attendance in attendees {
							if (PFUser.currentUser() != nil && attendee.attendeeId == PFUser.currentUser()!.objectId!) {
								attended = true
							break
							}
						}
					
						if (attended == false) {
							nearbyEvents.addObject(event)
						}
					}
				}
			}
		}
		
		
		// Sort by closest to furthest
		nearbyEvents.sortedArrayWithOptions(.Concurrent, usingComparator: { (event1, event2) -> NSComparisonResult in
			let location1 = CLLocation(latitude: (event1 as! Event).geoLocation!.latitude!.doubleValue, longitude: (event1 as! Event).geoLocation!.longitude!.doubleValue)
			let location2 = CLLocation(latitude: (event2 as! Event).geoLocation!.latitude!.doubleValue, longitude: (event2 as! Event).geoLocation!.longitude!.doubleValue)
			let distance1 : NSNumber = NSNumber(double: location.distanceFromLocation(location1))
			let distance2 : NSNumber = NSNumber(double: location.distanceFromLocation(location2))
			return distance1.compare(distance2)
		})
		
		
		// Update UI
		self.events = (nearbyEvents.copy()) as! [Event]
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			
			print("We have \(self.events.count) events..")
			self.tableView.reloadData()
			
			self.updateBlock?()
			
		})
	}
}
