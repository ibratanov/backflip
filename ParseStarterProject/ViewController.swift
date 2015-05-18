//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    //unique UUID password associated with device
    let passwordUnique = UIDevice.currentDevice().identifierForVendor.UUIDString
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var signUpLabel: UILabel!
    
    @IBAction func logIn(sender: AnyObject) {
        
        var error = ""
        
        if username.text == "" {
            
            error = "Please enter a phone number"
            
        }
        
        if count(username.text) != 12 {
            
            error = "Please enter a valid phone number"
            
        }
            
        if error != "" {
            
            displayAlert("Error in form", error: error)
            
        } else {
   
            
            PFUser.logInWithUsernameInBackground(username.text, password:passwordUnique) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    
                    
                    println("Logged in")
                    
                    self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                    
                    
                } else {
                    
                    var user = PFUser()
                    user.username = self.username.text
                    user.password = self.passwordUnique
                    
                    user.signUpInBackgroundWithBlock {
                        (succeeded, error) -> Void in
                        if error == error {
                            
                            println("Signed up")
                            
                            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                            
                        } else {
                            
                            println(error)
                            println("Jon")
                            
                        }
                    }
                    
                }
            }
            
            
            
            
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
            
                   println(PFUser.currentUser())
            
            
        }
    }
    
//hide navigation bar when this view is about to be displayed
    override func viewWillAppear(animated: Bool) {
    
        self.navigationController?.navigationBarHidden = true
        
    }
//keeps nav bar
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    
}

