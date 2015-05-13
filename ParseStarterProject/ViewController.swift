//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var signupActive = true
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
    
    
    @IBOutlet var alreadyRegistered: UILabel!
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var signUpLabel: UILabel!
    
    
    @IBOutlet var signUpToggleButton: UIButton!
    
    @IBAction func toggleSignUp(sender: AnyObject) {
        
        if signupActive == true {
            
            signupActive = false
            
            signUpLabel.text = "Use the form below to login"
            
            signUpButton.setTitle("Log In", forState: UIControlState.Normal)
            
            alreadyRegistered.text = "Not Registered?"
            
            signUpToggleButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            
            
        } else {
            
            signupActive = true
            
            signUpLabel.text = "Use the form below to sign up"
            
            signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            alreadyRegistered.text = "Already Registered?"
            
            signUpToggleButton.setTitle("Log In", forState: UIControlState.Normal)
            
        }
        
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        var error = ""
        
        if username.text == "" || password.text == "" {
            
            error = "Please enter a username and password"
            
        }
            
        if error != "" {
            
            displayAlert("Error in form", error: error)
            
        } else {
   
           
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            
            if signupActive == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text

                    user.signUpInBackgroundWithBlock {
                        (succeeded:Bool, signupError:NSError?) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if signupError == nil {
                         //Hooray you are signed up
                            println("signed up")
                            
                            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                            
                        } else {
                            
                            if let errorString = signupError!.userInfo?["error"] as? NSString {
                                
                                error = errorString as! String
                                
                            // Show the errorString somewhere and let the user try again.
                        } else {
                                
                            error = "Please try again"
                        }
                            
                            self.displayAlert("Could not sign up", error: error)
                   
                        }
                      }
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text, password:password.text) {
                    (user: PFUser?, signupError:NSError?) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signupError == nil {
                        
                        self.performSegueWithIdentifier("jumpToUserTable", sender: self)
                        
                        println("logged in")
                        
                        
                    } else {
                       
                        if let errorString = signupError!.userInfo?["error"] as? NSString {
                            
                            error = errorString as! String
                            
                            // Show the errorString somewhere and let the user try again.
                        } else {
                            
                            error = "Please try again later"
                        }
                        
                        self.displayAlert("Could not log in", error: error)
    
                        
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       println(PFUser.currentUser())
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("jumpToUserTable", sender: self)
            
            
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

