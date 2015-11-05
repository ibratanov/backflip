//
//  EventEditingView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-02.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation

class EventEditingView : PopoverView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
	var event : Event?
	var tableView : UITableView?
	
	var eventName : UITextField?
	var eventSwitch : UISwitch?
	
	
	override init()
	{
		super.init()
		
		self.tableView = UITableView(frame: self.view.bounds, style: .Plain)
		self.tableView?.dataSource = self
		self.tableView?.delegate = self
		self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView?.estimatedRowHeight = 88
		self.view.addSubview(self.tableView!)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//-------------------------------------
	// MARK: View Layout
	//-------------------------------------
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.tableView?.frame = self.view.bounds
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		self.tableView?.frame = self.view.bounds
	}
	
	
	
	//-------------------------------------
	// MARK: Table View Delegate
	//-------------------------------------
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 2
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return 66
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = self.tableView?.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath)
		cell?.selectionStyle = .None
		
		if (indexPath.row == 0) {
			
			cell?.textLabel!.text = "Event Name"
			
			eventName = UITextField(frame: CGRectMake(self.view.bounds.size.width - 230, 0, 220, 66))
			eventName?.adjustsFontSizeToFitWidth = true
			eventName?.textColor = UIColor.blackColor()
			eventName?.placeholder = "Event name"
			eventName?.text = event?.name
			eventName?.textColor = UIColor.grayColor()
			eventName?.keyboardType = .Default
			eventName?.returnKeyType = .Done
			eventName?.backgroundColor = UIColor.clearColor()
			eventName?.autocorrectionType = .No
			eventName?.autocapitalizationType = .None
			eventName?.textAlignment = .Right
			eventName?.clearButtonMode = .Never
			eventName?.delegate = self
			cell?.contentView.addSubview(eventName!)
			
		} else if (indexPath.row == 1) {
			
			cell?.textLabel!.text = "Private Event"
			
			eventSwitch = UISwitch(frame: CGRectMake(self.view.bounds.size.width - 55, 16, 94, 44))
			eventSwitch!.on = !(event!.live!.boolValue)
			
			cell?.contentView.addSubview(eventSwitch!)
		}
		
		
		return cell!
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row == 0) {
			eventName?.becomeFirstResponder()
		} else if (indexPath.row == 1) {
			eventSwitch?.setOn(!(eventSwitch!.on), animated: true)
		}
	}
	
	
	//-------------------------------------
	// MARK: TextField Delegate
	//-------------------------------------
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
	{
		let newLength = textField.text!.characters.count + string.characters.count - range.length;
		
		return newLength < 26
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		if (textField.text!.characters.count < 1) {
			return false
		}
		
		eventName?.resignFirstResponder()
		eventName?.endEditing(true)
		
		return true
	}
	
}
