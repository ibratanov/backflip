//
//  BFPreviewViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-17.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class BFPreviewViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
{
	
	/**
	 * Event
	*/
	var event: Event?
	
	/**
	 * Table View
	*/
	internal var tableView: UITableView!
	
	/**
	 * Cell Heights
	*/
	internal var cellHeights: [NSInteger : CGFloat] = [NSInteger : CGFloat]()
	
	internal var headerImageView: UIImageView?
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	
	
	// ----------------------------------------
	//  MARK: - View Loading
	// ----------------------------------------
	
	override func loadView()
	{
		super.loadView()

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Checkin", style: .Plain, target: nil, action: "")
		self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red:0,  green:0.467,  blue:1, alpha:1)
		
		self.tableView = UITableView(frame: self.view.bounds, style: .Plain)
		self.tableView.dataSource = self
		self.tableView.delegate = self
		
		self.tableView.separatorColor = UIColor.clearColor()
		
		self.tableView.registerClass(BFPreviewLocationCell.self, forCellReuseIdentifier: BFPreviewLocationCell.identifier)
		self.tableView.registerClass(BFPreviewDescriptionCell.self, forCellReuseIdentifier: BFPreviewDescriptionCell.identifier)
		self.tableView.registerClass(BFPreviewHeaderCell.self, forCellReuseIdentifier: BFPreviewHeaderCell.identifier)
		self.tableView.registerClass(BFPreviewPhotoCell.self, forCellReuseIdentifier: BFPreviewPhotoCell.identifier)
		
		self.view.addSubview(self.tableView)

	}

	
	override func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		self.tableView.frame = self.view.bounds
	}
	
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		
		// Ticket button
		if (self.event?.ticketUrl != nil) {
			self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Tickets", style: .Plain, target: nil, action: "")
			self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red:0,  green:0.467,  blue:1, alpha:1)
			self.navigationItem.leftBarButtonItem?.target = self
			self.navigationItem.leftBarButtonItem?.action = "ticketsButtonPressed:"
		} else {
			self.navigationItem.leftBarButtonItem = nil
		}
	}
	
	
	// ----------------------------------------
	//  MARK: - Table View (Delegate)
	// ----------------------------------------
	
	@available(iOS 2.0, *)
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if (self.cellHeights[indexPath.row] == nil) {
			return 0.0
		}
		
		return self.cellHeights[indexPath.row]!
	}
	
	@available(iOS 7.0, *)
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return (self.cellHeights[indexPath.row] != nil) ? self.cellHeights[indexPath.row]! : 88.0
	}
	
	
	@available(iOS 2.0, *)
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void
	{
		print("Selected cell \(indexPath.row)")
	}
	
	
	// ----------------------------------------
	//  MARK: - Table View (Data source)
	// ----------------------------------------
	
	@available(iOS 2.0, *)
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 4
	}
	
	// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
	// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
	@available(iOS 2.0, *)
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		var cell: BFPreviewCell?
		
		if (indexPath.row == 0) { // Header
			cell = tableView.dequeueReusableCellWithIdentifier(BFPreviewHeaderCell.identifier) as! BFPreviewHeaderCell
			self.headerImageView = (cell as! BFPreviewHeaderCell).backgroundImageView
		} else if (indexPath.row == 1) { // Description
			cell = tableView.dequeueReusableCellWithIdentifier(BFPreviewDescriptionCell.identifier) as! BFPreviewDescriptionCell
		} else if (indexPath.row == 2) { // Location Cell
			cell = tableView.dequeueReusableCellWithIdentifier(BFPreviewLocationCell.identifier) as! BFPreviewLocationCell
		} else if (indexPath.row == 3) { // Photos
			cell = tableView.dequeueReusableCellWithIdentifier(BFPreviewPhotoCell.identifier) as! BFPreviewPhotoCell
		}
	
		cell!.configureCell(withEvent: self.event!)
		self.cellHeights[indexPath.row] = cell!.cellHeight()
		
		return cell!
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Scroll View Delegate
	// ----------------------------------------
	
	func scrollViewDidScroll(scrollView: UIScrollView)
	{
		if (self.tableView.contentOffset.y < -44.0) {
			var headerRect = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 88.0)
			headerRect.origin.y = 44.0 + self.tableView.contentOffset.y
			headerRect.size.height = 44 + -self.tableView.contentOffset.y
		
			self.headerImageView?.frame = headerRect
		}
	}
	
	
	
	
	// ----------------------------------------
	//  MARK: - Button touch events
	// ----------------------------------------
	
	func ticketsButtonPressed(sender: AnyObject?)
	{
		if #available(iOS 9.0, *) {
			if let url = NSURL(string: self.event!.ticketUrl!) {
				self.dismissViewControllerAnimated(true, completion: { () -> Void in
					let safariViewController = SFSafariViewController(URL: url)
					let window : UIWindow? = UIApplication.sharedApplication().windows.first!
					window?.rootViewController!.presentViewController(safariViewController, animated: true, completion: nil)
				})
			}
		} else {
		    // Fallback on earlier versions
			print("We don't currently support iOS 8 for ticket purchasing..")
		}
	}
	
}
