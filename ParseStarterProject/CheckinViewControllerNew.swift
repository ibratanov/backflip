//
//  CheckinViewControllerNew.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation



class CheckinViewControllerNew : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarControllerDelegate
{
	var events : [Event] = []
	
	
	//-------------------------------------
	// MARK: UIPickerViewDelegate
	//-------------------------------------
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		if (self.events.count < 1) {
			return 1
		} else {
			return self.events.count
		}
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
	{
		if (self.events.count < 1) {
			return "No nearby events avaliable"
		} else {
			return self.events[row].name!
		}
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		NSLog("pickerView:didSelectRow:inComponent: (Index %i)", self.events.count)
		if (self.events.count < row) {
			return
		}
	}
	
	
}