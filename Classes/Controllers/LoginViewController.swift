
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
    
    let permissions : [String] = ["public_profile", "email"]
    
    
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
    
    @IBAction func fbLogin(sender: AnyObject) {
        
        facebookLogin()
        
    }
    
    func displayAlert(title:String,error: String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { action in

        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayNoInternetAlert() {
        let alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }
    
    func displayAlertUserBlocked(title:String, error: String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
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
    
    override func viewWillAppear(animated: Bool) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Login Screen")
        tracker.set("&uid", value: PFUser.currentUser()?.objectId)

        
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func facebookLogin() {
        
        if NetworkAvailable.networkConnection() == true {
            
            // Use the UUID to check if user has logged in before via phone method
            let deviceQuery = PFUser.query()
            deviceQuery?.whereKey("UUID", equalTo: UIDevice.currentDevice().identifierForVendor.UUIDString)
            deviceQuery?.limit = 1
            
            deviceQuery?.findObjectsInBackgroundWithBlock{ (results:[AnyObject]?, error: NSError?) -> Void in
                
                if error == nil{
                    if results?.count == 0 {
                        // If this is first login for both methods, sign them in with Facebook, intialize fields in DB
                        println("First time for Facebook signup method")
                        
                        PFFacebookUtils.logInInBackgroundWithReadPermissions(self.permissions) {
                            (user: PFUser? , error: NSError?) -> Void in
                            
                            if let user = user {
                                if user.isNew {
                                    
                                    
                                    //user.username = "Username"
                                    user.password = "Password"
                                    user["photosLiked"] = []
                                    user["nearbyEvents"] = []
                                    user["savedEvents"] = []
                                    user["savedEventNames"] = []
                                    user["blocked"] = false
                                    user["firstUse"] = true
                                    user["UUID"] = UIDevice.currentDevice().identifierForVendor.UUIDString
                                    user.saveInBackground()
                                    
                                    println("User signed up and logged in through facebook!")
                                    
                                    //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                    
                                } else {
                                    println("User logged in through facebook!")
                                    //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            } else {
                                println("Uh oh. The user cancelled the Facebook Login")
                            }
                            
                        }
                        
                    } else {
                        
                        
                        // User has already signed in before with phone method
                        // Link the phone number account with Facebook account
                        var oldUser = results!.first! as! PFUser
                        var phoneNumber = oldUser["phone"] as? String
                        
                        // If there is a phonenumber and facebook auth, they logged in with digits before, so link the account
                        //otherwise login regular way with FB
                        if phoneNumber != nil {
                            
                            // User logged in previously with Digits, login with number
                            // Link the user account to the Digits PF account
                            PFUser.logInWithUsername(phoneNumber!, password: phoneNumber!)
                            
                            if !PFFacebookUtils.isLinkedWithUser(results!.first! as! PFUser) {
                                PFFacebookUtils.linkUserInBackground(results!.first! as! PFUser, withReadPermissions: self.permissions, block: {
                                    (succeeded: Bool, error: NSError?) -> Void in
                                    if succeeded {
                                        println("Previous Backflip user account now linked with Facebook!")
                                        //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    } else {
                                        
                                        println(error)
                                    }
                                })
                                
                                
                            } else {
                                
                                if PFUser.currentUser() != nil{
                                    //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                                
                            }
                            // No phone number means either logged in only through facebook before
                        } else {
                            PFFacebookUtils.logInInBackgroundWithReadPermissions(self.permissions) {
                                (user: PFUser? , error: NSError?) -> Void in
                                
                                if error == nil {
                                    println("Logged in through Facebook")
                                    //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    
                                    println(error)
                                }
                                
                            }
                        }
                        
                    }
                } else {
                    
                    println(error)
                }
            }
        } else {
            
            displayNoInternetAlert()
            
        }
    }

    func didTapButton() {
        
        // Check for availability of network connection using Network available class
        if NetworkAvailable.networkConnection() == true {
            
            // Appearance settings for Digits pop up menu
            let digitsAppearance = DGTAppearance()
            digitsAppearance.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
            digitsAppearance.accentColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
            
            let digits = Digits.sharedInstance()
            
            // Initiate digits session
            digits.authenticateWithDigitsAppearance(digitsAppearance, viewController: nil, title: "Sign in to Backflip") { (session, error) in
                if session != nil {
					
					let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        let query = PFUser.query()
                        query!.whereKey("phone", equalTo: session.phoneNumber)
                        query!.limit = 1
                        var phoneResult = query!.findObjects()
                        
                        
                        // Use the UUID to check if user has logged in before via Facebook method
                        let deviceQuery = PFUser.query()
                        deviceQuery?.whereKey("UUID", equalTo: UIDevice.currentDevice().identifierForVendor.UUIDString)
                        deviceQuery?.limit = 1
                        
                        
                        // Result will have content if user has signed up already, will be nil if there is no internet
                        if (phoneResult == nil) {
                            self.displayNoInternetAlert()
                            
                        } else {
                            
                            if (phoneResult!.count == 0) {
                                deviceQuery?.findObjectsInBackgroundWithBlock{ (results:[AnyObject]?, error: NSError?) -> Void in
                                    if error == nil{
                                        if results!.count == 0 {
                                            
                                            // Results == 0 means user does not exist yet
                                            // If user proceeds with phone authentication, login with phonenumber to parse database
                                            if error == nil {
                                                // Initialize whatever data necessary for every user being put in database
                                                var user = PFUser()
                                                user.username = session.phoneNumber
                                                user.password = session.phoneNumber
                                                user["photosLiked"] = []
                                                user["nearbyEvents"] = []
                                                user["phone"] = session.phoneNumber
                                                user["savedEvents"] = []
                                                user["savedEventNames"] = []
                                                user["UUID"] = UIDevice.currentDevice().identifierForVendor.UUIDString
                                                user["blocked"] = false
                                                user["firstUse"] = true
                                                
                                                //Initialize the user in the database
                                                user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
                                                    
                                                    if error == nil {
                                                        
                                                        println("Signed Up")
                                                        //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                                        self.dismissViewControllerAnimated(true, completion: nil)
    
                                                        
                                                    } else {
                                                        println(error)
                                                    }
                                                }
                                            }
                                            
                                        } else {
                                            
                                            // User had logged in with facebook. Set the phonenumber in appropriate fields, login
                                            var oldUser = results!.first! as! PFUser
                                            
                                            PFUser.logInWithUsernameInBackground(oldUser.username!, password: "Password") { (user, error) -> Void in
                                                
                                                user!.username = session.phoneNumber
                                                user!.password = session.phoneNumber
                                                user!["phone"] = session.phoneNumber
                                                
                                                user!.saveInBackground()
                                                
                                                //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                                self.dismissViewControllerAnimated(true, completion: nil)
    
                                                
                                            }
                                        }
                                    } else {
                                        println(error)
                                    }
                                    
                                }
                                
                            } else {
                                
                                // User has logged in before with either facebook or digits
                                deviceQuery?.findObjectsInBackgroundWithBlock{ (results:[AnyObject]?, error: NSError?) -> Void in
                                    //User has phone number, logged in wih Digits
                                    var user = phoneResult?.first as! PFUser
                                    
                                    // Check for blocked. User must have account to be blocked. If not blocked, log in with username
                                    if (user["blocked"] as! Bool == false) {
                                        
                                        // Logged in with digits before, account may or may not be linked to FB. Login normally
                                        if user.username! == session.phoneNumber {
                                            // If user proceeds with phone authentication, login with phonenumber to parse database
                                            PFUser.logInWithUsernameInBackground(session.phoneNumber, password: session.phoneNumber) { (user , error) -> Void in
                                                
                                                // If older user, with no UUID, set the UUID
                                                var uuid = user?["UUID"] as? String
                                                
                                                if user != nil {
                                                    
                                                    if uuid == nil {
                                                        
                                                        user!["UUID"] = UIDevice.currentDevice().identifierForVendor.UUIDString
                                                        user?.saveInBackground()
                                                        
                                                    }
                                                    
                                                    println("Log in successful")
                                                    //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                                    self.dismissViewControllerAnimated(true, completion: nil)
    
                                                    
                                                }
                                            }
                                        } else {
                                            
                                            var oldUser = results!.first as! PFUser
                                            
                                            PFUser.logInWithUsernameInBackground(oldUser.username!, password: "Password") { (user, error) -> Void in
                                                
                                                user!.username = session.phoneNumber
                                                user!.password = session.phoneNumber
                                                user!["phone"] = session.phoneNumber
                                                
                                                user!.saveInBackground()
                                                
                                                //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                                self.dismissViewControllerAnimated(true, completion: nil)
    
                                                
                                            }
                                        }
                                        
                                    } else {
                                        Digits.sharedInstance().logOut()
                                        PFUser.logOut()
                                        println("User is Blocked")
                                        self.displayAlertUserBlocked("You have been blocked", error: "You have uploaded inappropriate content. Please email contact@getbackflip.com for more information.")
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        } else {
            displayNoInternetAlert()
        }
    }


    override func viewDidAppear(animated: Bool) {
        self.hidesBottomBarWhenPushed = true
        if NetworkAvailable.networkConnection() == true {
        // Check if the user is already logged in
            if PFUser.currentUser() != nil {
                let query = PFUser.query()
                query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                    if (error == nil && object != nil) {
                        let blocked = object!.valueForKey("blocked") as! Bool
                        if blocked == false {
                            // Segue done here instead of viewDidLoad() because segues will not be created at viewDidLoad()
                            println(Digits.sharedInstance().session())
                            //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                            self.performSegueWithIdentifier("toTabBar", sender: self)

                        }
                        else {
                            println("User is Blocked")
                            self.displayAlertUserBlocked("You have been blocked", error: "You have uploaded inappropriate content. Please email contact@getbackflip.com for more information.")
                        }
                    } else {
                        if (error != nil) {
                            println(error)
                        }
                        println("User was deleted, proceed to signup")
                        
                    }
                })
            }
        } else {
            displayNoInternetAlert()
        }
    }
}


