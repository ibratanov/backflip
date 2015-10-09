//
//  ViewController.swift
//  Backflip TV
//
//  Created by Jack Perry on 2015-10-09.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func updateDataTouched(sender: AnyObject)
	{
		BFDataFetcher.sharedFetcher.fetchData(false)
	}

}

