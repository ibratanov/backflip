
//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import DigitsKit


class LoginViewController: BFViewController, UINavigationControllerDelegate {

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
	
		FBSDKLoginManager.renewSystemCredentials { (results, error) -> Void in
			
			let login = FBSDKLoginManager()
			// When maddie decides: "user_hometown"
			login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, error) -> Void in
				if (error != nil) {
					print("Facebook login error")
					print(error)
				} else if (result.isCancelled == true) {
					print("Canceled")
				} else {
					print("Login success")
					
					
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
		Digits.sharedInstance().authenticateWithDigitsAppearance(digitsAppearance, viewController: nil, title: "Sign in to Backflip") { (session, error) in
			
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


