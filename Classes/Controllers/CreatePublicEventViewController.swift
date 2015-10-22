//
//  CreatePublicEventViewController.swift
//  Backflip
//
//  Created by Cody Mazza-Anthony on 2015-06-11.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import DigitsKit


class CreatePublicEventViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBAction func settingButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
    }
    
    var logoutButton = UIImage(named: "settings-icon") as UIImage!
    
    var userGeoPoint = PFGeoPoint()
    
    @IBAction func joinEvent(sender: AnyObject) {
        
        tabBarController?.selectedIndex = 0
    }
    // Quality of service variable for threading
    let qos = (Int(QOS_CLASS_BACKGROUND.rawValue))
    
    @IBOutlet var addressText: UIImageView!
    
    // @IBOutlet weak var albumview: AlbumViewController?
    // Disable navigation
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
		#if FEATURE_GOOGLE_ANALYTICS
            
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Create Public Event")
            //tracker.set("&uid", value: PFUser.currentUser()?.objectId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: PFUser.currentUser()?.objectId)
            
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
		#endif
    }
    var address2:String = ""
    
    var locationDisabled = false
    
    @IBOutlet var eventName: UITextField!
    
    @IBOutlet var userAddressButton: UIButton!
    
    var eventID : String?
    
    
    @IBOutlet var addressField: UILabel!
    
    
    func displayAlert(title:String, error: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func displayAlertLogout(title:String, error: String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { action in
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            self.hidesBottomBarWhenPushed = true
            self.performSegueWithIdentifier("logoutCreatePublic", sender: self)
            
            
        }))
		
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayNoInternetAlert() {
        Reachability.presentUnavailableAlert()
		print("no internet")
    }
    
    func getUserAddress() {
        let userLatitude = self.userGeoPoint.latitude
        let userLongitude = self.userGeoPoint.longitude
        
        if (self.locationDisabled == true) {
            self.addressField.text = "No location found"
        } else {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: userLatitude, longitude: userLongitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                if (error == nil) {
                    let placeArray = placemarks!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray[0]
                    
                    // Address dictionary
                    //println(placeMark.addressDictionary)
                    
                    // Location name
                    var streetNumber = ""
                    if let locationName = placeMark.addressDictionary?["Name"] as? NSString {
                        print(locationName)
                        streetNumber = locationName as String
                    }
                    
                    var streetAddress = ""
                    // Street address
                    if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString {
                        print(street)
                        streetAddress = street as String
                    }
                    
                    var cityName = ""
                    // City
                    if let city = placeMark.addressDictionary?["City"] as? NSString {
                        print(city)
                        cityName = city as String
                        
                    }
                    
                    // Zip code
                    if let zip = placeMark.addressDictionary?["ZIP"] as? NSString {
                        print(zip)
                    }
                    
                    // Country
                    var countryName = ""
                    if let country = placeMark.addressDictionary?["Country"] as? NSString {
                        print(country)
                        countryName = country as String
                    }
                    
                    let address = streetNumber + ", " + streetAddress
                    self.address2 = streetNumber + ", " + cityName + ", " + countryName
                    self.addressField.text = address
                } else {
                    self.displayNoInternetAlert()
                    print("could not generate location - no internet")
                    self.address2 = "No location found"
                    self.addressField.text = self.address2
                }
            })
        }
    }
    
    @IBAction func createEvent(sender: AnyObject)
	{
	
		
		// Validate event name
		guard eventName.text?.characters.count > 0 else {
			let alertController = UIAlertController(title: "Error", message: "Please enter a valid event name", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
			self.presentViewController(alertController, animated: true, completion: nil)
			
			return
		}
		
		
		// Validate address
		guard addressField.text?.characters.count > 0 else {
			let alertController = UIAlertController(title: "Error", message: "We're unable to detect your location. Please try again", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
			self.presentViewController(alertController, animated: true, completion: nil)
			
			return
		}
		
		
		BFParseManager.sharedManager.createEvent(self.eventName.text!, address: self.addressField.text!) { [weak self] (completed, error) -> Void in
			
			if (completed == false) {
				
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					
					PKHUD.sharedHUD.hide() // Vainity check
					
					var message = error?.description
					if (error?.code == 501) {
						message = "Event name already taken, please try again"
					}
					
					let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
					alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
					self?.presentViewController(alertController, animated: true, completion: nil)
					
				})
				
				return
			}
			
			print("Created new event '\(self?.eventName.text)'")
			
			
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				
				self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
				
			})
			
		}
		
	}
	
    
    // Function to grey out create event button unless more than 2 characters are entered
    func textCheck (sender: AnyObject) {
        
        let textField = sender as! UITextField
        var resp : UIResponder = textField
        while !(resp is UIAlertController) { resp = resp.nextResponder()!}
        let alert = resp as! UIAlertController
        alert.actions[1].enabled = (textField.text!.characters.count > 1)
        
    }
    
    // Delegate method to prevent typing in text over 25 characters in alertview
    // http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield
    // Information on how this delegate method works
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
	{
        return textField.text!.characters.count <= 25
    }
    
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        //self.performSegueWithIdentifier("eventsPage", sender: self)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
	
	
	@IBAction func cancelButton()
	{
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	override func loadView()
	{
		super.loadView()
		
		// Backflip Logo
		self.navigationItem.titleView = UIImageView(image: UIImage(named: "backflip-logo-white"))
	}
	
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Makes the keyboard pop up as soon as the view appears
        eventName.becomeFirstResponder()
        
		
        
        //Add delegate, this prevents users from typing text over 25 characters
        eventName.delegate = self
        
        if Reachability.validNetworkConnection() == true {
            
            //getUserAddress()
            
            PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
                if error == nil {
                    print(geoPoint, terminator: "")
                    self.userGeoPoint = geoPoint!
                }
                else {
                    print("Error with User Geopoint")
                    self.locationDisabled = true
                }
            }
        } else {
            displayNoInternetAlert()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.validNetworkConnection() == true {
            getUserAddress()
        } else {
            displayNoInternetAlert()
        }

    }
    
    // Two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func disablesAutomaticKeyboardDismissal() -> Bool {
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        eventName.resignFirstResponder()
        eventName.endEditing(true)
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
