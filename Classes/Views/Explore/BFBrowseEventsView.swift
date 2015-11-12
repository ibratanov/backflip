//
//  BFBrowseEventsView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-10.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

public class BFBrowseEventsView : UIView, UITableViewDataSource, UITableViewDelegate
{
	
	/**
	 * Events, array of `Event` objects
	*/
	public var events: [Event] = []
	private let eventCount = 8
	
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
			return CGFloat(eventCount * Int(BFBrowseEventCell.contentHight))
		}
	}
	
	
	
	
	// ----------------------------------------
	//  MARK: - Table View (Data Source)
	// ----------------------------------------
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return Int(eventCount) // events.count
	}
	
	@available(iOS 2.0, *)
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(BFBrowseEventCell.reuseIdentifier, forIndexPath: indexPath) as! BFBrowseEventCell
		
		cell.backgroundImageView.image = UIImage(named: "Scene-4")
		cell.textLabel?.text = "Startup OH TO"
		cell.detailTextLabel?.text = "Toronto, Ontario"
		cell.rightDetailLabel.text = "Tomorrow"
		
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

	
}
