//
//  EventViewController.swift
//  ParseStarterProject
//
//  Created by Zachary Lefevre on 2015-05-19.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class CheckinViewController: UIViewController {
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            // Commented out below, causes flashing view when display is dismissed
            //self.dismissViewControllerAnimated(false, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var eventField: UITextField!

    @IBOutlet weak var checkInButton: UIButton!
    @IBAction func checkInClicked(sender: AnyObject) {
        
        var error = ""
        
        if (eventField.text == "") {
            
            error = "Please enter an event name."
            
        } else if (count(eventField.text) < 2)  {
            
            error = "Please enter a valid event name."
        }
        
        if (error != "") {
            
            displayAlert("Event creation error:", error: error)
            
        } else {
        
            var event = PFObject(className:"Event")
            event["eventName"] = eventField.text
            //event["startTime"] =
            event.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                    println("success \(event.objectId)")
                } else {
                    // There was a problem, check error.description
                    println("fail")
                }
            }
            
        }
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
    }
    
    // Two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
