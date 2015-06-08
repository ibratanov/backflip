//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate {
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
  

    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
        //set to false, to prevent login screen flashes on failed login attempt
        self.dismissViewControllerAnimated(false, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
//phone number validation function
    func validate(value: String) -> Bool {
        
        let phoneRegex = "^\\d{3}-\\d{3}-\\d{4}$"
        
        var compare = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        var resultBool =  compare.evaluateWithObject(value)
        
        return resultBool
        
    }

    
    //unique UUID password associated with device
    let passwordUnique = UIDevice.currentDevice().identifierForVendor.UUIDString
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var signUpLabel: UILabel!
    
    @IBAction func logIn(sender: AnyObject) {
        
        var error = ""
        
        if (username.text == "") {
            
            error = "Please enter a phone number."
            
        }
        
        if (self.validate(username.text) == false)  {
            
            error = "Please enter a valid phone number."
        }
        
        
        if (error != "") {
            
            displayAlert("Sign in error:", error: error)
            
        } else {
   
            
            PFUser.logInWithUsernameInBackground(username.text, password:passwordUnique) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    
                    
                    println("Logged in")
                    
                    //self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                    self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                    
                    
                    
                } else {
                    
                    var user = PFUser()
                    user.username = self.username.text
                    user["phone"] = self.username.text
                    user.password = self.passwordUnique
                    user["UUID"] = self.passwordUnique
                    user["photoLikeList"] = []
                    
                    user.signUpInBackgroundWithBlock {
                        (succeeded, error) -> Void in
                        if error == nil {
                            
                            println("Signed up")
                            
                            //self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                            self.performSegueWithIdentifier("jumpToEventCreation", sender: self)

                            
                        } else {
                            
                            println(error)
                            
                        }
                    }
                    
                }
            }
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Return closes keyboard
       self.username.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //check if the user is already logged in
        if PFUser.currentUser() != nil {
            
            //segue done here instead of viewDidLoad() because segues will not yet have been created at viewDidLoad()
            //self.performSegueWithIdentifier("jumpToUserTable", sender: self)
            self.performSegueWithIdentifier("jumpToEventCreation", sender: self)

            println(PFUser.currentUser()!)
            
        }
    }
    
//two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
   
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
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

