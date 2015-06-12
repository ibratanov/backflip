//
//  CreatePublicEventViewController.swift
//  Backflip
//
//  Created by Cody Mazza-Anthony on 2015-06-11.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class CreatePublicEventViewController: UIViewController {
    
    
    @IBAction func joinPublicEvent(sender: AnyObject) {
        performSegueWithIdentifier("backToCheckIn", sender: sender)
    }
    
    @IBOutlet var publicEvent: UITextField!
    
    @IBAction func createEvent(sender: AnyObject) {
    
    }
    
    
    @IBAction func privateTribe(sender: AnyObject) {
    }
    
    
    @IBAction func pastEvents(sender: AnyObject) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
