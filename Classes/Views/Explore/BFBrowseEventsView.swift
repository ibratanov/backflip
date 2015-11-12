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
		self.titleLabel.font = UIFont.systemFontOfSize(10, weight: UIFontWeightSemibold)
		
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
		self.tableView.frame = CGRectMake(0, 45, self.bounds.width, self.contentHeight)

	}

	public var contentHeight: CGFloat {
		get {
			return CGFloat(self.events.count * Int(BFBrowseEventCell.contentHight))
		}
	}
	
	
	
	
	// ----------------------------------------
	//  MARK: - Table View (Data Source)
	// ----------------------------------------
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return Int(self.events.count)
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
		
		cell.imageView!.nk_prepareForReuse()
		if let image = event.previewImage {
			let imageUrl = NSURL(string: image.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))
			cell.backgroundImageView!.nk_setImageWithURL(imageUrl!)
		}
		
	}
	
	
	// ----------------------------------------
	//  MARK: - Data
	// ----------------------------------------
	
	private func loadEvents(animated: Bool)
	{
		self.events.removeAll()
	
		
		BFLocationManager.sharedManager.fetchLocation(.House) { (location, error) -> Void in
			
			if (error != nil) {
				return // self.handleLocationError(error)
			}
			
			let config = PFConfig.currentConfig()
			let _events = Event.MR_findAll() as! [Event]
			let nearbyEvents : NSMutableArray = NSMutableArray()
			
			let radius = config["nearby_events_radius"] != nil ? config["nearby_events_radius"]! as! NSNumber : 10 // Default: 10km (It's really in meters here 'cause of legacy, turns to Kms below)
			let region : CLCircularRegion = CLCircularRegion(center: location!.coordinate, radius: (radius.doubleValue * 1000), identifier: "nearby-events-region")
			
			// Filter by event location and attancance
			for event : Event in _events {
				if (event.geoLocation != nil && event.live != nil && Bool(event.live!) == true && event.enabled != nil && Bool(event.enabled!) == true) {
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
			
			
			// Sort by closest to furthest
			nearbyEvents.sortedArrayWithOptions(.Concurrent, usingComparator: { (event1, event2) -> NSComparisonResult in
				let location1 = CLLocation(latitude: (event1 as! Event).geoLocation!.latitude!.doubleValue, longitude: (event1 as! Event).geoLocation!.longitude!.doubleValue)
				let location2 = CLLocation(latitude: (event2 as! Event).geoLocation!.latitude!.doubleValue, longitude: (event2 as! Event).geoLocation!.longitude!.doubleValue)
				let distance1 : NSNumber = NSNumber(double: location!.distanceFromLocation(location1))
				let distance2 : NSNumber = NSNumber(double: location!.distanceFromLocation(location2))
				return distance1.compare(distance2)
			})
			
			
			// Update UI
			self.events = (nearbyEvents.copy()) as! [Event]
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
			
				self.tableView.reloadData()
				if (self.updateBlock != nil) {
					self.updateBlock!()
				}
				
			})
			
		}

		
	}
}
