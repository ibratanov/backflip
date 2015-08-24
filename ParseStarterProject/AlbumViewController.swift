//
//  albumViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MobileCoreServices
import AssetsLibrary
import Foundation
import Photos
import MessageUI
import AVFoundation
import DigitsKit

let reuseIdentifier = "albumCell"

class AlbumViewController: UICollectionViewController,
    UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,  MWPhotoBrowserDelegate {
    
    var refresher: UIRefreshControl!
	
    // Title and ID of event passed from previous VC, based on selected row
    var eventId : String?
    var eventTitle: String?
	
	// Photo browser
	var browser : MWPhotoBrowser!
	
    
    var spinner : UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Variable for storing PFFile as image, pass through segue
    var images = [UIImage]()
    var postLogo = UIImage(named: "liked.png") as UIImage!
    var goBack = UIImage(named: "back") as UIImage!
    var cam = UIImage(named:"goto-camera") as UIImage!
    var newCam = UIImage(named:"goto-camera-full") as UIImage!
    
    // Arrays of image files full size
    var timesImages = [UIImage]()
    var likeImages = [UIImage]()
    var myImages = [UIImage]()
    
    
    // Tuple for sorting
    var imageFilesTemp : [(image: PFFile , likes: Int , id: String,date: NSDate, hqImage: PFFile)] = []
    
    // Arrays for like sort selected
	var collectionContent : [PFFile?] = []

	
    var imageFilesLikes : [PFFile?] = []
    var objectIdLikes = [String]()
    var datesLikes : [NSDate?] = []
    var hqLikes : [PFFile?] = []
    
    // Arrays for time sort selected
    var imageFilesTime : [PFFile?] = []
    var objectIdTime = [String]()
    var datesTime : [NSDate?] = []
    var hqTime : [PFFile?] = []
    
    //Arrays for when my photos is selected
    var myPhotos : [PFFile?] = []
    var myObjectId = [String]()
    var myDate : [NSDate?] = []
    var hqMyPhotos : [PFFile?] = []
    
    // Checker for sort button. Sort in chronological order by default.
    var sortedByLikes = true
    var myPhotoSelected = false
    var fullScreen = false
    var posted = false
    
    // Display alert function for when an album timer is going to run out
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayNoInternetAlert() {
        var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewChanger (sender: UISegmentedControl) {
        
        if NetworkAvailable.networkConnection() == true {
            switch sender.selectedSegmentIndex {
                
                // Rating Sort
            case 0 :    sortedByLikes = true
            myPhotoSelected = false
            updatePhotos()
                
                // Time Sort
            case 1:     sortedByLikes = false
            myPhotoSelected = false
            updatePhotos()

                
                // My Photos
            case 2 :    myPhotoSelected = true
            displayMyPhotos()
                
                
                
            default:
                println("default")
                
            }
        } else {
            
            var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to internet to access content.")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")
            
        }
    }
    
    // Occurs for when a user adds a photo, we want the photo to show up instantly
    override func viewDidAppear(animated: Bool) {
        
        
        
        if NetworkAvailable.networkConnection() == true {
            // fullscreen is false, posted is true
            if posted == true && fullScreen == false {

                if myPhotoSelected == false {
                    updatePhotos()

                    

                } else {
                    displayMyPhotos()


                }
                
                //self.collectionView?.reloadSections(NSIndexSet(index: 0))
                
            }
            fullScreen = false
        } else {
            
            var alert = NetworkAvailable.networkAlert("Error", error: "Connect to internet to access content")
            self.presentViewController(alert, animated: true, completion: nil)
            print("no internet")
            
        }
        
    }
    
    // Segway back to event history page
    func seg() {
        
        PFQuery.clearAllCachedResults()
        
		
        //self.performSegueWithIdentifier("backToEvent", sender: self)
        
    }
    

	
    
    
	@IBAction func smsShare(sender: AnyObject)
	{
		var user = "filler";
		if (PFUser.currentUser() != nil) {
			user  = PFUser.currentUser()!.objectId!
		}
		
		var params = [ "referringUsername": "\(user)", "referringOut": "AVC", "eventId":"\(self.eventId!)", "eventTitle": "\(self.eventTitle!)"]
		Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
			if (error != nil) {
				NSLog("Branch short URL generation failed, %@", error);
			} else {
				
				let album = Album(text: String(format:"Check out the photos from %@ on ", self.eventTitle!), url: url);
				
				// Now we share.
				let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [album, url], applicationActivities: nil)
				activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop]
				self.presentViewController(activityViewController, animated: true, completion: nil)
				
			}
			
		})
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated);
		
		self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
	}
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()

		let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
		
		flow.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
		flow.itemSize = CGSizeMake((self.view.frame.size.width/3)-1, (self.view.frame.size.width/3)-1);
		flow.minimumInteritemSpacing = 1;
		flow.minimumLineSpacing = 1;
	}
	
	
    override func viewDidLoad() {
        
        super.viewDidLoad()
		
		

        //self.tabBarController?.tabBar.hidden = true
        // Pull down to refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView?.alwaysBounceVertical = true
        
        // Spinner initialization and characteristics
        spinner.frame = CGRectMake(0.0, 0.0, 50.0, 50.0)
        spinner.center = self.view.center
        spinner.hidden = false
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        spinner.color = UIColor.blackColor()
        self.view.addSubview(spinner)
        self.view.bringSubviewToFront(spinner)

        // Initial load of images
        if NetworkAvailable.networkConnection() == true {
            // fullscreen is false, posted is true
            if fullScreen == false || posted == true {

                if myPhotoSelected == false {

                        self.updatePhotos()

                } else {

                        self.displayMyPhotos()
                }

            }
        } else {
            
            var alert = NetworkAvailable.networkAlert("Error", error: "Connect to internet to access content")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")
            
        }
        
        // Booleans for determining if view needs to be reloaded
        //self.fullScreen = false
        //self.posted = false
        
        //--------------- LIKE/TIME/MY PHOTOS ---------------
        
        // Initialize segmented control button
        let items = ["SORT BY LIKES", "SORT BY TIME", "MY PHOTOS"]
        let segC = UISegmentedControl(items: items)
        
        // Persistence of segmented control selection
        if sortedByLikes == true && myPhotoSelected == false {
            
            segC.selectedSegmentIndex = 0
            
        }
        
        if sortedByLikes == false && myPhotoSelected == false {
            
            segC.selectedSegmentIndex = 1
            
        }
        
        if myPhotoSelected == true  {
            
            segC.selectedSegmentIndex = 2
            
        }
        
        // Defines where seg control is positioned
        let frame: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = frame.width
        let screenHeight = frame.height
		var superCenter = view.center
        segC.frame = CGRectMake(CGRectGetMinX(frame),64,screenWidth,30)
        
        // Set characteristics of segmented controller
        var backColor : UIColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
        var titleFont : UIFont = UIFont(name: "Avenir", size: 12.0)!
        
        // Implement base colors on our segmented control
        segC.tintColor = UIColor.clearColor()
        
        // Attributes for non selected segments
        var segAttributes = [
            
            NSForegroundColorAttributeName : backColor,
            
            NSFontAttributeName : titleFont,
            
        ]
        
        // Attributes for when segment is selected
        var underline  =  NSUnderlineStyle.StyleSingle.rawValue
        var underlineColor : UIColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
        var segAttributes1 = [
            
            NSForegroundColorAttributeName : backColor,
            
            NSFontAttributeName : titleFont,
            
            NSUnderlineStyleAttributeName : underline,
            
            NSUnderlineColorAttributeName : underlineColor
            
        ]
        
        // Implement the above attributes on our segmented control
        segC.setTitleTextAttributes(segAttributes as [NSObject:AnyObject],forState: UIControlState.Normal)
        segC.setTitleTextAttributes(segAttributes1 as [NSObject:AnyObject], forState: UIControlState.Selected)
        
        // Add targets, initialize segmented control
        segC.addTarget(self, action: "viewChanger:", forControlEvents: .ValueChanged)
        
        //--------------- Draw UI ---------------
		self.title = self.eventTitle;
		
        // Post photo button new
        let postPhoto = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        postPhoto.setImage(cam, forState: .Normal)
        postPhoto.frame = CGRectMake(0, self.view.frame.size.height-55, self.view.frame.size.width, 75)
        postPhoto.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        postPhoto.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(postPhoto)
        
        // Set VC color
        self.collectionView!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        // Pushes collection view down, higher value pushes collection view downwards, and push from bottom of screen (3rd number)
        collectionView?.contentInset = UIEdgeInsetsMake(0.0,0.0,88.0,0.0)
        self.automaticallyAdjustsScrollViewInsets = false
		
		if (eventId == nil) {
			return ;
		}
		
        if NetworkAvailable.networkConnection() == true  {
            // Initialize date comparison components
            let currentTime = NSDate()
            let cal = NSCalendar.currentCalendar()
            let components = NSDateComponents()
            components.hour = 48
            let components2 = NSDateComponents()
            components2.hour = 24
            var eventQuery = PFQuery(className: "Event")
            
            eventQuery.selectKeys(["endTime"])
            
            eventQuery.getObjectInBackgroundWithId(eventId!){ (objects, error) -> Void in
                if error == nil {
                    if let endTime: AnyObject = objects?.objectForKey("endTime") {
                        //endDate has been set and is valid
                        
                        //TODO: determine how this can be set automatically
                        let endTime = objects?.objectForKey("endTime") as! NSDate
                        
                        //date is the end time of event plus 48hours
                        let date = cal.dateByAddingComponents(components, toDate: endTime, options: NSCalendarOptions.allZeros)
                        
                        // Event is still active (currentTime < expiry time)
                        if currentTime.compare(date!) == NSComparisonResult.OrderedAscending {
                            
                            // Event is no longer active (currentTime > expiry time)
                        } else if currentTime.compare(date!) == NSComparisonResult.OrderedDescending {
                            
                        }
                        
                    } else {
                        //endDate has not been set or was invalid
                    }
                    
                    
                } else {
                    
                    println(error)
                    
                }
            }
        } else {
            displayNoInternetAlert()
        }
    }
    
    func refresh(sender: AnyObject) {
        
        if NetworkAvailable.networkConnection() == true {
            if myPhotoSelected == false {
                
                updatePhotos()
                self.refresher.endRefreshing()
                
            } else {
                
                displayMyPhotos()
                self.refresher.endRefreshing()
            }
            
        } else {
            displayNoInternetAlert()
            self.refresher.endRefreshing()
        }
        
    }
    
    
    func displayMyPhotos() {
        
        spinner.startAnimating()
        
        
        // Clean the arrays for use again
        self.imageFilesTemp.removeAll(keepCapacity: true)
        
        self.myPhotos.removeAll(keepCapacity: true)
        self.myObjectId.removeAll(keepCapacity: true)
        
        self.imageFilesLikes.removeAll(keepCapacity: true)
        self.objectIdLikes.removeAll(keepCapacity: true)
        self.datesLikes.removeAll(keepCapacity: true)
        
        self.imageFilesTime.removeAll(keepCapacity: true)
        self.objectIdTime.removeAll(keepCapacity: true)
        self.datesTime.removeAll(keepCapacity: true)
        
        self.images.removeAll(keepCapacity: true)
        
        let qos = (Int(QOS_CLASS_BACKGROUND.value))
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            
            // Load information from parse db -- purely for flag checking
            var getUploadedImages = PFQuery(className: "Event")
            getUploadedImages.limit = 1
            getUploadedImages.selectKeys(["photos"])
            getUploadedImages.whereKey("objectId", equalTo: self.eventId!)
            
            
            // Retrieval from corresponding photos from relation to event
            var eventNames = getUploadedImages.findObjects() //as! PFObject
            
            if (eventNames == nil || eventNames!.count == 0) {
                
                println("error")
                dispatch_async(dispatch_get_main_queue()) {
                    self.spinner.stopAnimating()
                }

            } else {
                
                var object = eventNames!.first as! PFObject
                var photos = object["photos"] as! PFRelation
                var photoList = photos.query()!.findObjects()
                
                if (photoList == nil || photoList!.count == 0) {

                   println("no photos")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.spinner.stopAnimating()
                    }

                    
                } else {
                    
                    // End flag checking load
                    
                    var query = PFQuery(className: "EventAttendance")
                    query.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
                    query.whereKey("eventID", equalTo: self.eventId!)
                    query.selectKeys(["photosLiked", "photosLikedID", "flagged", "blocked"])
                    
                    var queryResult = query.findObjects()
  
                        if (queryResult == nil || queryResult!.count == 0) {
                            
                            println("no photos")
                            self.myPhotos = []
                            self.myObjectId = []
                            dispatch_async(dispatch_get_main_queue()) {
                                self.spinner.stopAnimating()
                            }

                            
                        } else {
                            
                           
                            //TODO: Check if this is an actual issue when events & users are properly linked up
                            if (queryResult!.count != 0) {
                                var eventAttendance = queryResult!.first as! PFObject
                                var pList = eventAttendance["photosLiked"] as! [PFFile]
                                var ids = eventAttendance["photosLikedID"] as! [String]

                                
                                // Check for the list count being 0
                                if pList.count == 0 {
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.spinner.stopAnimating()
                                    }

                                    self.myPhotos = []
                                    self.myObjectId = []
                                }
                        
                                var index = 0
                                for photo in pList {
                                    // Ensure the image wasn't flagged or blocked
                                    // TODO: Look into this temp fix for array out of bounds issue with flagged photos
                                    if (index < ids.count) {
                                        var id = ids[index]
                                        var hidden = false
                                        for p in photoList! {
                                            if (p.objectId == ids[index] && ((p["flagged"] as! Bool) == true || (p["blocked"] as! Bool) == true)) {
                                                hidden = true
                                            }
                                        }
                                   
                                        if (!hidden) {

                                            self.myPhotos.append(photo)
                                            self.myObjectId.append(ids[index])
                                            
                           

                                        }
                                        
                                        index++
                                    }
                                }
                            }
                        }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView?.reloadSections(NSIndexSet(index: 0))
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }

    
    // TODO: Smart loading of photos - only reload photos which are new/were modified
    func updatePhotos() {

        self.spinner.startAnimating()

        // Clean all our arrays for use again
        self.imageFilesTemp.removeAll(keepCapacity: true)
        
        self.myPhotos.removeAll(keepCapacity: true)
        self.myObjectId.removeAll(keepCapacity: true)
        
        
        self.imageFilesLikes.removeAll(keepCapacity: true)
        self.objectIdLikes.removeAll(keepCapacity: true)
        self.datesLikes.removeAll(keepCapacity: true)
        self.hqLikes.removeAll(keepCapacity: true)
        
        self.imageFilesTime.removeAll(keepCapacity: true)
        self.objectIdTime.removeAll(keepCapacity: true)
        self.datesTime.removeAll(keepCapacity: true)
        self.hqTime.removeAll(keepCapacity: true)
        
        self.images.removeAll(keepCapacity: true)
		
		if (self.eventId == nil) {
			NSLog("eventID == nil, NOP'in out..");
			return ;
		}
		
        let qos = (Int(QOS_CLASS_BACKGROUND.value))
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            
            // Load information from parse db
            var getUploadedImages = PFQuery(className: "Event")
            getUploadedImages.limit = 1
            getUploadedImages.selectKeys(["photos"])
            getUploadedImages.whereKey("objectId", equalTo: self.eventId!)
            
            // Retrieval from corresponding photos from relation to event
            var eventArray = getUploadedImages.findObjects()
            
            if (eventArray == nil || eventArray!.count == 0) {
                
                println("No Photos/No Updates")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.spinner.stopAnimating()
                }
                
            } else {
                
                var object = eventArray!.first as! PFObject
                var photos = object["photos"] as! PFRelation

                
                var photoListQuery = photos.query()!
                photoListQuery.limit = 300
                var photoList = photoListQuery.findObjects()

                if (photoList == nil || photoList!.count == 0) {
                    
                    println("No Photos/No Updates")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.spinner.stopAnimating()
                    }

                    
                } else {
                            
                    for photo in photoList! {
                        
                        // Ensure the image wasn't flagged or blocked
                        if ((photo["flagged"] as! Bool) == false && (photo["blocked"] as! Bool) == false) {
                            // Fill our array of tuples for sorting
                            let tup = (image: photo["thumbnail"] as! PFFile, likes: photo["upvoteCount"] as! Int, id: photo.objectId!! as String,date: photo.createdAt!! as NSDate, hqImage: photo["image"] as! PFFile)
                            
                            self.imageFilesTemp.append(tup)
                        }
                        
                    }

                    // Sort tuple of images by likes, and fill new array with photos in order of likes
                    self.imageFilesTemp.sort{ $0.likes > $1.likes}
                    
                    for (image, likes, id, date, hqImage) in self.imageFilesTemp {
                        
                        self.imageFilesLikes.append(image)
                        self.objectIdLikes.append(id)
                        self.datesLikes.append(date)
                        self.hqLikes.append(hqImage)
                        
                    }
                    
                    // Sort tuple of images, fill the array with photos in order of time
                    self.imageFilesTemp.sort{ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
                    
                    for (image, likes, id, date, hqImage) in self.imageFilesTemp {
                        
                        self.imageFilesTime.append(image)
                        self.objectIdTime.append(id)
                        self.datesTime.append(date)
                        self.hqTime.append(hqImage)
                        
                    }
                    
                     dispatch_async(dispatch_get_main_queue()) {
						self.collectionView?.reloadData()
                        // self.collectionView?.reloadSections(NSIndexSet(index: 0))
                        self.spinner.stopAnimating()
                        
                    }
                }
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //self.images.removeAll(keepCapacity: true)
        
        self.collectionView?.reloadData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
	

	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
	{
		var supplementaryView : AnyObject! = nil
		if kind == UICollectionElementKindSectionHeader {
			supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header-view", forIndexPath: indexPath)
		} else if kind == UICollectionElementKindSectionFooter {
			supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer-view", forIndexPath: indexPath)
		}
		
		return supplementaryView as! UICollectionReusableView
	}
	
//	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//		var v : UICollectionReusableView! = nil
//		if kind == UICollectionElementKindSectionHeader {
//			v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:"Header", forIndexPath:indexPath) as! UICollectionReusableView
//			if v.subviews.count == 0 {
//				let segItems = ["Sort By Time", "Sort By Likes", "My Photos"];
//
//				v.addSubview(UISegmentedControl(items: segItems))
//				v.frame = CGRectMake(0,0,375.0,88.0)
//			}
//			
//			let seg = v.subviews[0] as! UISegmentedControl
//			
//		}
//		return v
//	}
	
	
	func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt
	{
		if sortedByLikes == true && myPhotoSelected == false {
			
			return UInt(imageFilesTime.count)
			
		} else if sortedByLikes == false && myPhotoSelected == false{
			
			return UInt(imageFilesLikes.count)
			
		} else {
			
			// Returns the count of cells, which may be less or more, depending on myphotos array
			return UInt(myPhotos.count)
		}
	}
	
	
	func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol!
	{
		var photo : MWPhoto = MWPhoto(URL: NSURL(string: "https://www.petfinder.com/wp-content/uploads/2012/11/dog-how-to-select-your-new-best-friend-thinkstock99062463.jpg"))
		if sortedByLikes == true && myPhotoSelected == false {
			let file:PFFile = imageFilesTime[Int(index)]!
			photo = MWPhoto(URL: NSURL(string: file.url!))
		} else if sortedByLikes == false && myPhotoSelected == false {
			let file:PFFile = imageFilesLikes[Int(index)]!
			photo = MWPhoto(URL: NSURL(string: file.url!))
		} else {
			let file:PFFile = myPhotos[Int(index)]!
			photo = MWPhoto(URL: NSURL(string: file.url!))
		}
		
		return photo
	}
	
	
	func photoBrowser(photoBrowser: MWPhotoBrowser!, actionButtonPressedForPhotoAtIndex index: UInt)
	{
		// NSLog("photoBrowser select action button index = %@", index);
	}
	
	func sharePhoto()
	{
		// let photo = self.photoBrowser(browser, photoAtIndex: browser?.currentIndex)
		
		//let imageData : UIImage = self.fullScreenImage.image!;
		let image = Image(text: "Photo");
		
		let reportImage = ReportImageActivity();
		// NSNotificationCenter.defaultCenter().addObserver(self, selector: "flagPhoto:", name: "BFImageReportActivitySelected", object: nil)
		
		
		let vc = UIActivityViewController(activityItems: [image], applicationActivities:[reportImage])
		vc.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePrint]
		self.presentViewController(vc, animated: true, completion: nil)
		
		NSLog("Will share photo now.. photo index = %i", browser.currentIndex)
		print(browser?.currentIndex)
	}
	
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		// Create browser (must be done each time photo browser is
		// displayed. Photo browser objects cannot be re-used)
		
		browser = MWPhotoBrowser(delegate: self)
		
		let shareBarButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sharePhoto")
		browser?.navigationItem.rightBarButtonItem = shareBarButton
			
		// Set options
		browser?.displayActionButton = true // Show action button to allow sharing, copying, etc (defaults to YES)
		browser?.displayNavArrows = false // Whether to display left and right nav arrows on toolbar (defaults to NO)
		browser?.displaySelectionButtons = false // Whether selection buttons are shown on each image (defaults to NO)
		browser?.zoomPhotosToFill = true // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
		browser?.alwaysShowControls = true // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
		browser?.enableGrid = false // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
		browser?.startOnGrid = false // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
		
		// Optionally set the current visible photo before displaying
		NSLog("-[ collectionView:didSelectItemAtIndexPath:] %@", indexPath)
		browser?.setCurrentPhotoIndex(UInt(indexPath.row))
		
		self.navigationController?.pushViewController(browser!, animated: true)
	}
	
	
	
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        
        if sortedByLikes == true && myPhotoSelected == false {
            
            return imageFilesTime.count
            
        } else if sortedByLikes == false && myPhotoSelected == false{
            
            return imageFilesLikes.count
            
        } else {
            
            // Returns the count of cells, which may be less or more, depending on myphotos array
            return myPhotos.count
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let albumCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumViewCell
		
        // Image view is of type PFImageView, allows parse to do the loading of the files in the cells
        
        if sortedByLikes == false && myPhotoSelected == false {
            
            if imageFilesTime.count == 0 {
                
                println("No Photos/No Update")
                
            } else {
                
                // Temp image until actual image loads CAUSES MEMORY WARNING ON MANY REFRESH
                //albumCell.imageView.image = UIImage(contentsOfFile: "backfliplogo80.png")
				
				// albumCell.imageView.setImageWithURL(NSURL(string: imageFilesTime[indexPath.row].url!))
                
            }
            
        } else if sortedByLikes == true && myPhotoSelected == false {
            
            if imageFilesLikes.count == 0 {
                
                println("No Photos/No Update")
                
            } else {
                
                
                // Temp image until actual image loads
                albumCell.imageView.image = UIImage(contentsOfFile: "backfliplogo80.png")
                
                //albumCell.imageView.file = imageFilesLikes[indexPath.row]
                //albumCell.imageView.loadInBackground()
                
                
                
            }
            
        } else if myPhotoSelected == true {
            
            if myPhotos.count == 0 {
                
                println("No Photos/No Update")
                // TODO: Check if necessary
                // albumCell.imageView.image = nil
                
                
            } else {
                
                // Temp image until actual image loads
                albumCell.imageView.image = UIImage(contentsOfFile: "backfliplogo80.png")
                
                //albumCell.imageView.file = myPhotos[indexPath.row]
                //albumCell.imageView.loadInBackground()
            }
        }
        
        albumCell.layer.shouldRasterize = true
        albumCell.layer.rasterizationScale = UIScreen.mainScreen().scale
        return albumCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if NetworkAvailable.networkConnection() == true {
            if segue.identifier == "display-event-image" {
                
                var moveVC: FullScreenViewController = segue.destinationViewController as! FullScreenViewController
                var selectedCellIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
                moveVC.eventId = eventId!
                moveVC.eventTitle = eventTitle!
                fullScreen = true
                
                // Sorted by time (from newest to oldest)
                if self.sortedByLikes == false && self.myPhotoSelected == false {
                    if self.objectIdTime.count == 0 || self.datesTime.count == 0 {
                        displayNoInternetAlert()
                    } else {
                        moveVC.tempArray = objectIdTime
                        moveVC.selectedIndex = selectedCellIndex!.row
                        moveVC.imageFiles = hqTime
                        dump(hqTime)
                    }
                    
                } else if self.sortedByLikes == true && self.myPhotoSelected == false {
                    // Sorted by like count
                    if self.objectIdLikes.count == 0 || self.datesLikes.count == 0 {
                        displayNoInternetAlert()
                    } else {
                        
                        moveVC.tempArray = objectIdLikes
                        moveVC.selectedIndex = selectedCellIndex!.row
                        moveVC.imageFiles = hqLikes
                        dump(hqLikes)
                        
                    }
                } else {
                    
                    if self.myObjectId.count == 0 {
                        displayNoInternetAlert()
                    } else {
                        
                        moveVC.tempArray = myObjectId
                        moveVC.selectedIndex = selectedCellIndex!.row
                        moveVC.imageFiles = myPhotos

                    }
                }
            }
        } else {
            displayNoInternetAlert()
        }
    }
    
@IBAction func takePhoto(sender: UIButton)  {
        var testCamera = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Button capture")
            
            testCamera.delegate = self
            testCamera.sourceType = UIImagePickerControllerSourceType.Camera;
            testCamera.mediaTypes = [kUTTypeImage]
            testCamera.allowsEditing = false
            
           // self.presentViewController(testCamera, animated: true, completion: nil)
        }
    }

}



extension AlbumViewController : UICollectionViewDelegateFlowLayout
{
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		return CGSizeMake((self.view.frame.size.width/3) - 1, (self.view.frame.size.width/3) - 1)
	}
}
