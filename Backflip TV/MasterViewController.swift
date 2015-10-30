//
//  MasterViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-20.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


class MasterViewController : UITableViewController
{
	var events : [PFObject] = []
	var selectedIndex : NSIndexPath?
	
	internal var activityIndicator : UIActivityIndicatorView?
	
	var detailViewController : DetailViewController?
	
	
	
	override weak var preferredFocusedView: UIView? { get { return self.tableView } }
	
	
	// --------------------------------------
	//  MARK: View loading
	// --------------------------------------
	
	override func loadView()
	{
		super.loadView()
		
		self.detailViewController = (self.splitViewController?.viewControllers[1] as? UINavigationController)?.viewControllers.first as? DetailViewController
		self.tableView.remembersLastFocusedIndexPath = true
		
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		SVProgressHUD.appearance().defaultStyle = .Dark
		SVProgressHUD.show()
		
		self.fetchData()
	}
	

	
	// --------------------------------------
	//  MARK: Table View
	// --------------------------------------
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.events.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier("cell-identifier", forIndexPath: indexPath)
		
		// Cell configuration
		let event = self.events[indexPath.row]
		cell.textLabel?.text = event["eventName"] as? String
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let event = self.events[indexPath.row]
		self.detailViewController?.title = event["eventName"] as? String
		
		self.detailViewController?.event = event
	}
	
	
	
	// --------------------------------------
	//  MARK: Data retrival
	// --------------------------------------
	
	func fetchData()
	{
		guard Reachability.validNetworkConnection() else {
			print("Not fetching data due to lack of network connection")
			return
		}
		
		let attendanceQuery = PFQuery(className: "EventAttendance")
		attendanceQuery.whereKey("attendeeID", equalTo: "PH2JGLM1Ml")
		attendanceQuery.includeKey("event")
		attendanceQuery.findObjectsInBackgroundWithBlock { (attendances, error) -> Void in
			
			print("We have \(attendances?.count) results..")
			guard attendances?.count > 0 else { return }
			
			self.events.removeAll()
			for attendance in attendances! {
				if (attendance["event"] != nil) {
					self.events.append((attendance["event"] as! PFObject))
				}
			}
			
			SVProgressHUD.dismissWithDelay(0.1)
			
			self.tableView.reloadData()
			
			self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
		}
		
	}
	
	
}