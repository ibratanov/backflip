
//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import DigitsKit


class LoginViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var termsTextView: UITextView!
    
    
    @IBAction func termsOfService(sender: AnyObject) {
        if let url = NSURL(string: "http://getbackflip.com/eula") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    @IBAction func privacyPolicy(sender: AnyObject) {
        if let url = NSURL(string: "http://getbackflip.com/privacy") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        
        didTapButton()
        
    }
    
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { action in

        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayAlertUserBlocked(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //Hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        termsTextView.editable = false
        termsTextView.userInteractionEnabled = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didTapButton() {
        
        // Appearance settings for Digits pop up menu
        let digitsAppearance = DGTAppearance()
        digitsAppearance.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        digitsAppearance.accentColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
        let digits = Digits.sharedInstance()
        
        // Initiate digits session
        digits.authenticateWithDigitsAppearance(digitsAppearance, viewController: nil, title: "Sign in to Backflip") { (session, error) in
            
            if session != nil {
                
                let query = PFUser.query()
                //query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                //query!.getObject//Id(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                query!.whereKey("phone", equalTo: session.phoneNumber)
                query!.limit = 1
                var result = query!.findObjects()
                var user = result?.first as! PFUser
                if (user["blocked"] as! Bool == false) {
                    
                        // If user proceeds with phone authentication, login with phonenumber to parse database
                        PFUser.logInWithUsernameInBackground(session.phoneNumber, password: session.phoneNumber) { (user , error) -> Void in
                            
                            if user != nil {
                                
                                println("Log in successful")
                                self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                
                            } else {
                                
                                // Initialize whatever data necessary for every user being put in database
                                var user = PFUser()
                                user.username = session.phoneNumber
                                user.password = session.phoneNumber
                                user["photosLiked"] = []
                                user["nearbyEvents"] = []
                                user["phone"] = session.phoneNumber
                                user["savedEvents"] = []
                                user["savedEventNames"] = []
                                user["blocked"] = false
                                user["firstUse"] = true
                                
                                user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
                                    
                                    if error == nil {
                                        
                                        println("Signed Up")
                                        self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                        
                                    } else {
                                        
                                        println(error)
                                    }
                                }
                            }
                        }
                } else {
                    Digits.sharedInstance().logOut()
                    println("User is Blocked")
                    self.displayAlertUserBlocked("You have been blocked", error: "You have uploaded inappropriate content. Please email contact@getbackflip.com for more information.")
                }
            }
        }
    }


    override func viewDidAppear(animated: Bool) {
        
        // Check if the user is already logged in
        if PFUser.currentUser() != nil {
            let query = PFUser.query()
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                println(object)
                var blocked = object!.valueForKey("blocked") as! Bool
                if blocked == false {
                    // Segue done here instead of viewDidLoad() because segues will not be created at viewDidLoad()
                    self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                }
                else {
                    println("User is Blocked")
                    self.displayAlertUserBlocked("You have been blocked", error: "You have uploaded inappropriate content. Please email contact@getbackflip.com for more information.")
                }
            })
        }
    }
}

