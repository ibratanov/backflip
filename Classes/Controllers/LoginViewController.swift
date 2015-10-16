
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
        Reachability.presentUnavailableAlert()
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

		#if SNAPSHOT
			let tripleTap = UITapGestureRecognizer(target: self, action: "snapshopLogin")
			tripleTap.numberOfTapsRequired = 3
			self.backgroundImageView.userInteractionEnabled = true
			self.backgroundImageView.addGestureRecognizer(tripleTap)
		#endif

		print(self.backgroundImageView.gestureRecognizers)
    }
    
    override func viewWillAppear(animated: Bool) {
        // facebookButton.hidden = true

		#if FEATURE_GOOGLE_ANALYTICS
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Login Screen")
            //tracker.set("&uid", value: PFUser.currentUser()?.objectId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: PFUser.currentUser()?.objectId)
            
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
		#endif
    }


	#if SNAPSHOT

		func snapshopLogin()
		{
			PFUser.logInWithUsernameInBackground("+14168375145", password: "+14168375145", block: { (user : PFUser?, error) -> Void in

				if (error == nil && user != nil) {

					self.dismissViewControllerAnimated(true, completion: nil)
				} else {
					print(error)
				}

			})
		}

	#endif


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func facebookLogin()
	{
	
		let login = FBSDKLoginManager()
		login.logInWithReadPermissions(["public_profile", "email"]) { (result, error) -> Void in
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
				
				BFParseManager.sharedManager.login(nil, facebookResult: result, uponCompletion: { (completed, error) -> Void in
						
					if (completed == true) {
						self.dismissViewControllerAnimated(true, completion: nil)
					}
					
						
					print("Login completed = \(completed)")
					print("Login error = \(error)")
						
				})
				
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
				deviceQuery?.whereKey("UUID", equalTo: UIDevice.currentDevice().uniqueDeviceIdentifier())
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
								user["phone"] = id
								user["facebook_id"] = Int(id)
								user["facebook_name"] = fullName
								user["email"] = emailAddress
								user["savedEvents"] = []
								user["savedEventNames"] = []
								user["UUID"] = UIDevice.currentDevice().uniqueDeviceIdentifier()
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
										
										user!["facebook_id"] = Int(id)
										user!["facebook_name"] = fullName
										user!["email"] = emailAddress
										user!["UUID"] = UIDevice.currentDevice().uniqueDeviceIdentifier()
										user!.saveInBackgroundWithBlock(nil)
										
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
						PFUser.logInWithUsernameInBackground(user!.username!, password: "backflip-pass-"+user!.username!, block: { (user : PFUser?, error) -> Void in
							
							if (error == nil && user != nil) {
								
								user!["facebook_id"] = Int(id)
								user!["facebook_name"] = fullName
								user!["email"] = emailAddress
								user!["UUID"] = UIDevice.currentDevice().uniqueDeviceIdentifier()
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
	

    func didTapButton() {
		
		UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
		
		// Network reachability checking
		guard Reachability.validNetworkConnection() else {
			return Reachability.presentUnavailableAlert()
		}

			
		// Appearance settings for Digits pop up menu
		let digitsAppearance = DGTAppearance()
		digitsAppearance.backgroundColor = UIColor.whiteColor()
		digitsAppearance.accentColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
			
		
		// Initiate digits session
		let digits = Digits.sharedInstance()
		digits.authenticateWithDigitsAppearance(digitsAppearance, viewController: nil, title: "Sign in to Backflip") { (session, error) in
			
			UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
				
			BFParseManager.sharedManager.login(session, facebookResult: nil, uponCompletion: { (completed, error) -> Void in
				
				if (completed == true) {
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				
				print("Login completed = \(completed)")
				print("Login error = \(error)")
				
			})
			
		}
    }


    override func viewDidAppear(animated: Bool) {
        self.hidesBottomBarWhenPushed = true
        if Reachability.validNetworkConnection() == true {
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
                            // self.performSegueWithIdentifier("toTabBar", sender: self)

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


