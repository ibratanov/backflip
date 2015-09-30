
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
    @IBOutlet weak var facebookButton: UIButton!
	@IBOutlet weak var backgroundImageView: UIImageView!
    
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
        print("no internet")
    }
    
    func displayAlertUserBlocked(title:String, error: String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //Hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.sendSubviewToBack(backgroundImageView)
		termsTextView.editable = false
        termsTextView.userInteractionEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        // facebookButton.hidden = true
		
		#if FEATURE_GOOGLE_ANALYTICS
			let tracker = GAI.sharedInstance().defaultTracker
			tracker.set(kGAIScreenName, value: "Login Screen")
			tracker.set("&uid", value: PFUser.currentUser()?.objectId)
        
			let builder = GAIDictionaryBuilder.createScreenView()
			tracker.send(builder.build() as [NSObject : AnyObject])
		#endif
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func facebookLogin()
	{
	
		let login = FBSDKLoginManager()
		login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, error) -> Void in
			
			if (error != nil) {
				print("Facebook login error")
				print(error)
			} else if (result.isCancelled == true) {
				print("Canceled")
			} else {
				print("Login success")
				
				if (FBSDKAccessToken.currentAccessToken() != nil) {
					self.fetchDataAndLogin(result.token.tokenString, id: result.token.userID)
				}
			}
			
		}
		
    }
	
	func fetchDataAndLogin(token: String?, id: String?)
	{
		let graphRequest = FBSDKGraphRequest(graphPath: id!, parameters: ["fields": "id, about, email, first_name, last_name, name"])
		graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
			
			if (error != nil) {
				
			} else {
			
				let emailAddress = result.valueForKey("email") as! String
				let id = result.valueForKey("id") as! String
				let fullName = result.valueForKey("name") as! String
				
				print(result)
				print("^^ Facebook graph result")
				
				
				let deviceQuery = PFUser.query()
				deviceQuery?.whereKey("UUID", equalTo: UIDevice.currentDevice().identifierForVendor!.UUIDString)
				deviceQuery?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
					
					if (error == nil && results?.count == 0) {
						
						let userQuery = PFUser.query()
						userQuery?.whereKey("username", equalTo: id)
						userQuery?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
						
							if (error == nil && results?.count < 1) {
								
								let user = PFUser()
								user.username = id
								user.password = "backflip-pass-"+id
								user["photosLiked"] = []
								user["nearbyEvents"] = []
								user["phone"] = id
								user["facebook_id"] = Int(id)
								user["facebook_name"] = fullName
								user["email"] = emailAddress
								user["savedEvents"] = []
								user["savedEventNames"] = []
								user["UUID"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
								user["blocked"] = false
								user["firstUse"] = true
								user.signUpInBackgroundWithBlock({ (success, error) -> Void in
									
									if (error == nil) {
										self.dismissViewControllerAnimated(true, completion: nil)
									} else {
										print(error)
									}
									
								})
								
							} else if (error == nil && results?.count > 0) {

								PFUser.logInWithUsernameInBackground(id, password: "backflip-pass-"+id, block: { (user, error) -> Void in
									
									if (error == nil) {
										print(user)
										self.dismissViewControllerAnimated(true, completion: nil)
									} else {
										print(error)
									}
									
								})
								
							} else {
								print(error)
							}
							
						})
						
					} else if (error == nil && results?.count > 0) {
						
						let user = results?.first as? PFUser
						PFUser.logInWithUsernameInBackground(user!.username!, password: user!.username!, block: { (user : PFUser?, error) -> Void in
							
							if (error == nil && user != nil) {
								
								user!["facebook_id"] = Int(id)
								user!["facebook_name"] = fullName
								user!["email"] = emailAddress
								user!["UUID"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
								user!.saveInBackgroundWithBlock(nil)
								
								self.dismissViewControllerAnimated(true, completion: nil)
							} else {
								print(error)
							}
							
						})
						
					} else {
						print("Login error")
						print(error)
					}
					
				})
				
			}
		}
		
	}
	
	func returnUserData()
	{
		let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
		graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
			
			if ((error) != nil)
			{
				// Process error
				print("Error: \(error)")
			}
			else
			{
				print("fetched user: \(result)")
				let userName : NSString = result.valueForKey("name") as! NSString
				print("User Name is: \(userName)")
				let userEmail : NSString = result.valueForKey("id") as! NSString
				print("User ID is: \(userEmail)")
			}
		})
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
                        let phoneResult = query!.findObjects()
                        
                        
                        // Use the UUID to check if user has logged in before via Facebook method
                        let deviceQuery = PFUser.query()
                        deviceQuery?.whereKey("UUID", equalTo: UIDevice.currentDevice().identifierForVendor!.UUIDString)
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
                                                let user = PFUser()
                                                user.username = session.phoneNumber
                                                user.password = session.phoneNumber
                                                user["photosLiked"] = []
                                                user["nearbyEvents"] = []
                                                user["phone"] = session.phoneNumber
                                                user["savedEvents"] = []
                                                user["savedEventNames"] = []
                                                user["UUID"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
                                                user["blocked"] = false
                                                user["firstUse"] = true
                                                
                                                //Initialize the user in the database
                                                user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
                                                    
                                                    if error == nil {
                                                        
                                                        print("Signed Up")
                                                        //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                                        self.dismissViewControllerAnimated(true, completion: nil)
    
                                                        
                                                    } else {
                                                        print(error)
                                                    }
                                                }
                                            }
                                            
                                        } else {
                                            
                                            // User had logged in with facebook. Set the phonenumber in appropriate fields, login
                                            let oldUser = results!.first! as! PFUser
                                            
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
                                        print(error)
                                    }
                                    
                                }
                                
                            } else {
                                
                                // User has logged in before with either facebook or digits
                                deviceQuery?.findObjectsInBackgroundWithBlock{ (results:[AnyObject]?, error: NSError?) -> Void in
                                    //User has phone number, logged in wih Digits
                                    let user = phoneResult?.first as! PFUser
                                    
                                    // Check for blocked. User must have account to be blocked. If not blocked, log in with username
                                    if (user["blocked"] as! Bool == false) {
                                        
                                        // Logged in with digits before, account may or may not be linked to FB. Login normally
                                        if user.username! == session.phoneNumber {
                                            // If user proceeds with phone authentication, login with phonenumber to parse database
                                            PFUser.logInWithUsernameInBackground(session.phoneNumber, password: session.phoneNumber) { (user , error) -> Void in
                                                
                                                // If older user, with no UUID, set the UUID
                                                let uuid = user?["UUID"] as? String
                                                
                                                if user != nil {
                                                    
                                                    if uuid == nil {
                                                        
                                                        user!["UUID"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
                                                        user?.saveInBackground()
                                                        
                                                    }
                                                    
                                                    print("Log in successful")
                                                    //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                                                    self.dismissViewControllerAnimated(true, completion: nil)
    
                                                    
                                                }
                                            }
                                        } else {
                                            
                                            let oldUser = results!.first as! PFUser
                                            
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
                                        print("User is Blocked")
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
                            // print(Digits.sharedInstance().session())
                            //self.performSegueWithIdentifier("jumpToEventCreation", sender: self)
                            self.performSegueWithIdentifier("toTabBar", sender: self)

                        }
                        else {
                            print("User is Blocked")
                            self.displayAlertUserBlocked("You have been blocked", error: "You have uploaded inappropriate content. Please email contact@getbackflip.com for more information.")
                        }
                    } else {
                        if (error != nil) {
                            print(error)
                        }
                        print("User was deleted, proceed to signup")
                        
                    }
                })
            }
        } else {
            displayNoInternetAlert()
        }
    }
}


