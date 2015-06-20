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


let reuseIdentifier = "albumCell"

class AlbumViewController: UICollectionViewController,UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    var refresher: UIRefreshControl!
    
    
    

    //------------------Camera Att.-----------------
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    var testCamera = UIImagePickerController()

    
    //@IBOutlet weak var imageView: UIImageView!
    var imageViewContent = UIImage()
    var overlayView: UIView?
    var image = UIImage()
    var picker = UIImagePickerController()
    var zoomImage = (camera: true, display: true)
    var newMedia: Bool = true
    //TO-DO: Button pressed button released attributes
    

    //----------------------------------------
    
    // Title and ID of event passed from previous VC, based on selected row
    var eventId : String?
    var eventTitle: String?
    
    
    // Variable for storing PFFile as image, pass through segue
    var images = [UIImage]()
    var postLogo = UIImage(named: "liked.png") as UIImage!
    var goBack = UIImage(named: "goto-eventhistory-icon") as UIImage!
    var share = UIImage(named: "share-icon") as UIImage!
    var newCam = UIImage(named:"goto-camera-full") as UIImage!

    
    // Tuple for sorting
    var imageFilesTemp : [(image: PFFile , likes: Int , id: String,date: NSDate)] = []
    
    // Arrays for like sort selected
    var imageFilesLikes = [PFFile]()
    var objectIdLikes = [String]()
    var datesLikes = [NSDate]()
    
    // Arrays for time sort selected
    var imageFilesTime = [PFFile]()
    var objectIdTime = [String]()
    var datesTime = [NSDate]()
    
    //Arrays for when my photos is selected
    var myPhotos = [PFFile]()
    var myObjectId = [String]()
    var myDate = [NSDate]()
    
    // Checker for sort button. Sort in chronological order by default.
    var sortedByLikes = true
    var myPhotoSelected = false
    
    // Display alert function for when an album timer is going to run out
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBOutlet weak var spinner:UIActivityIndicatorView!
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func viewChanger (sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
            // Rating
            case 0 :    sortedByLikes = true
                        myPhotoSelected = false
                        updatePhotos()
                        self.collectionView?.reloadData()
            
            // Time
            case 1:     sortedByLikes = false
                        myPhotoSelected = false
                        updatePhotos()
                        self.collectionView?.reloadData()
            
            // My Photos
            case 2 :    myPhotoSelected = true
                        displayMyPhotos()
                        self.collectionView?.reloadData()
            
            
            default:
                
                println("hi")
            
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    func seg() {
        
        //self.performSegueWithIdentifier("backButton", sender: self)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func smsShare() {
        
        var params = [ "referringUsername": "User1",
            "referringUserId": "12345",  "pictureId": "987666",
            "pictureURL": "http://yoursite.com/pics/987666",
            "pictureCaption": "BOOM" ]
        
        // this is making an asynchronous call to Branch's servers to generate the link and attach the information provided in the params dictionary --> so inserted spinner code to notify user program is running
        
        //self.spinner.startAnimating()
        //disable button
        
        
        Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
            if (error == nil) {
                if MFMessageComposeViewController.canSendText() {
                    
                    let messageComposer = MFMessageComposeViewController()
                    
                    messageComposer.body = String(format: "Check this out: %@", url)
                    
                    messageComposer.messageComposeDelegate = self
                    
                    self.presentViewController(messageComposer, animated: true, completion:{(Bool) in
                        // stop spinner on main thread
                        //self.spinner.stopAnimating()
                    })
                } else {
                    
                    //self.spinner.stopAnimating()
                    
                    var alert = UIAlertController(title: "Error", message: "Your device does not allow sending SMS or iMessages.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //--------------- LIKE/TIME/MY PHOTOS ---------------

        // Initialize segmented control button
        let items = ["LIKES", "TIME", "MY PHOTOS"]
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
        println(frame)
        let screenWidth = frame.width
        let screenHeight = frame.height
        var superCenter = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
        segC.frame = CGRectMake(CGRectGetMinX(frame),64,screenWidth,30)
        
        // Set characteristics of segmented controller
        var backColor : UIColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
        var titleFont : UIFont = UIFont(name: "Avenir", size: 12.0)!
        var textColor : UIColor = UIColor.whiteColor()
        
        
        // Implement base colors on our segmented control
        segC.tintColor = UIColor.whiteColor()
        segC.backgroundColor = UIColor.whiteColor()
        
        // Attributes for non selected segments
        var segAttributes = [
            
            NSForegroundColorAttributeName : backColor,
            
            NSFontAttributeName : titleFont,
            
            NSBackgroundColorAttributeName : textColor
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
        self.view.addSubview(segC)
        
        //--------------- Draw UI ---------------
        
        // Hide UI controller item
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64))
        navBar.backgroundColor =  UIColor.whiteColor()
        
        // Removes faint line under nav bar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()

        navBarItem.title = eventTitle
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let back = UIButton.buttonWithType(.System) as! UIButton
        back.setBackgroundImage(goBack, forState: .Normal)
        back.frame = CGRectMake(15, 31, 22, 22)
        back.addTarget(self, action: "seg", forControlEvents: .TouchUpInside)
        navBar.addSubview(back)
        
        // Right nav bar button item
        let shareAlbum = UIButton.buttonWithType(.System) as! UIButton
        shareAlbum.setBackgroundImage(share, forState: .Normal)
        shareAlbum.frame = CGRectMake(self.view.frame.size.width-37,31,22,22)
        shareAlbum.addTarget(self, action: "smsShare", forControlEvents: .TouchUpInside)
        navBar.addSubview(shareAlbum)
        
        self.view.addSubview(navBar)
        
        // Post photo button
        let postPhoto = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        postPhoto.setImage(newCam, forState: .Normal)
        postPhoto.frame = CGRectMake((self.view.frame.size.width/2)-40, self.view.frame.height-60, 80, 80)
        postPhoto.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(postPhoto)
        
        // Set VC color
        self.collectionView!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        // Pushes collection view down, higher value pushes collection view downwards
        collectionView?.contentInset = UIEdgeInsetsMake(94.0,0.0,0.0,0.0)
        self.automaticallyAdjustsScrollViewInsets = false
 
        // Pull down to refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView?.alwaysBounceVertical = true

        
        // Initialize date comparison components
        let currentTime = NSDate()
        let cal = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.hour = 48
        let components2 = NSDateComponents()
        components2.hour = 24
        var eventQuery = PFQuery(className: "Event")
        println(self.eventId)
        
        eventQuery.getObjectInBackgroundWithId(eventId!){ (objects, error) -> Void in
            if error == nil {
                
                //TODO: determine how this can be set automatically
                let endTime = objects?.objectForKey("endTime") as! NSDate
                
                //date is the end time of event plus 48hours
                let date = cal.dateByAddingComponents(components, toDate: endTime, options: NSCalendarOptions.allZeros)
                
                // Event is still active (currentTime < expiry time)
                if currentTime.compare(date!) == NSComparisonResult.OrderedAscending {

                //self.displayAlert("Heads Up!", error: "Active")

                    
                // Event is no longer active (currentTime > expiry time)
                } else if currentTime.compare(date!) == NSComparisonResult.OrderedDescending {
                    
                    //self.displayAlert("Heads Up!", error: "Inactive")
                    
                    // Delete if the event is no longer active
                    //objects?.deleteInBackground()
                    
                }

                
            } else {
                
                println(error)
                
            }
            
        }
        if myPhotoSelected == false {
            
            updatePhotos()
            
        } else {
            
            displayMyPhotos()
        }

    }
    
    func refresh(sender: AnyObject) {
        
        if myPhotoSelected == false {
            
            updatePhotos()
            self.collectionView?.reloadData()
            self.refresher.endRefreshing()
            
        } else {
            
            displayMyPhotos()
            self.collectionView?.reloadData()
            self.refresher.endRefreshing()
        }
        
    }
    
    
    func displayMyPhotos() {
        
        
        // Clean our arrays for use again
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
        
        
        
        
        var query = PFQuery(className: "EventAttendance")
        query.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("eventID", equalTo: eventId!)
        
        var photoObjects = query.findObjects()?.first as! PFObject
        
        var pList = photoObjects["photosLiked"] as! [PFFile]
        var id = photoObjects["photosLikedID"] as! [String]
        
        for photos in pList {
            
            self.myPhotos.append(photos)
            
            
        }
        
        for ids in id {
            
            
            self.myObjectId.append(ids)
        }
        
        
        

        
        
        /*// Load information from parse db
        var getUploadedImages = PFQuery(className: "Event")
        getUploadedImages.limit = 1000
        getUploadedImages.whereKey("objectId", equalTo: eventId!)
        
        // Retrieval from corresponding photos from relation to event
        var object = getUploadedImages.findObjects()?.first as! PFObject
        
    
        var photos = object["photos"] as! PFRelation

        
        // List of objects in the photo relation
        var photosList = photos.query()?.findObjects() as! [PFObject]
  
        
        var displayPhotos : [PFFile]
        
        for photo in photosList {
            
            var userList = photo["usersLiked"] as! [String]
            var currPhoto = photo["thumbnail"] as! PFFile
            
            for users in userList {
                
                if users == PFUser.currentUser()?.username {
                    
                    self.myPhotos.append(currPhoto)
                    self.myObjectId.append(photo.objectId!)
                    
                }
            }
            
        }

        dump(myPhotos)
        dump(myObjectId)*/
        
    }
    
    
    // TODO: Smart loading of photos - only reload photos which are new/were modified
    func updatePhotos() {
        
        // Clean all our arrays for use again
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
        
        // Load information from parse db
        var getUploadedImages = PFQuery(className: "Event")
        getUploadedImages.limit = 1000
        getUploadedImages.whereKey("objectId", equalTo: eventId!)
        
        // Retrieval from corresponding photos from relation to event
        var object = getUploadedImages.findObjects()?.first as! PFObject
        
        var photos = object["photos"] as! PFRelation
        
        var photoList = photos.query()?.findObjects() as! [PFObject]
                
                for photo in photoList {
                    
                    // Fill our array of tuples for sorting
                    let tup = (image: photo["thumbnail"] as! PFFile, likes: photo["upvoteCount"] as! Int, id: photo.objectId! as String,date: photo.createdAt! as NSDate)
                    
                    self.imageFilesTemp.append(tup)
                    
                    self.collectionView?.reloadData()
                    
                }
                
                // Sort tuple of images by likes, and fill new array with photos in order of likes
                self.imageFilesTemp.sort{ $0.likes > $1.likes}
                
                for (image, likes, id, date) in self.imageFilesTemp {
                    
                    self.imageFilesLikes.append(image)
                    self.objectIdLikes.append(id)
                    self.datesLikes.append(date)
                    
                }
                
                // Sort tuple of images, fill the array with photos in order of time
                self.imageFilesTemp.sort{ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
                
                for (image, likes, id, date) in self.imageFilesTemp {
                    
                    self.imageFilesTime.append(image)
                    self.objectIdTime.append(id)
                    self.datesTime.append(date)
                    
                }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.images.removeAll(keepCapacity: true)

        self.collectionView?.reloadData()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
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

        if sortedByLikes == false && myPhotoSelected == false {
            
            // Default, fill the cells with photos sorted by time
            imageFilesTime[indexPath.row].getDataInBackgroundWithBlock { (imageData, error) -> Void in
                
                if error == nil {
                    
                    let image = UIImage (data: imageData!)
                    self.images.append(image!)
                    
                    albumCell.imageView.image = image
                    
                } else {
                    
                    println(error)
                    
                }
                
            }
        } else if sortedByLikes == true && myPhotoSelected == false {
            
            // Fill the cells with the sorted photos by likes
            imageFilesLikes[indexPath.row].getDataInBackgroundWithBlock { (imageD,error) -> Void in
         
                if error == nil {
                    
                    let image = UIImage (data: imageD!)
                    self.images.append(image!)
                    
                    albumCell.imageView.image = image
                    
                } else {
                    
                    println(error)
                    
                }
                
            }
    
        } else if myPhotoSelected == true {
            
            
            myPhotos[indexPath.row].getDataInBackgroundWithBlock { (imgDat, error) -> Void in
                
                if error == nil {
                    
                    let image = UIImage(data: imgDat!)
                    self.images.append(image!)
                    
                    albumCell.imageView.image = image
                    
                    
                } else {
                    
                    println(error)
                }
 
            }
        }
        albumCell.layer.shouldRasterize = true
        albumCell.layer.rasterizationScale = UIScreen.mainScreen().scale    
        return albumCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "toFull" {
            
            var moveVC: FullScreenViewController = segue.destinationViewController as! FullScreenViewController
            var selectedCellIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
            moveVC.eventId = eventId!
            moveVC.eventTitle = eventTitle!
            
            // Sorted by time (from newest to oldest)
            if self.sortedByLikes == false && self.myPhotoSelected == false {

                moveVC.objectIdTemp = objectIdTime[selectedCellIndex!.row]
                
            } else if self.sortedByLikes == true && self.myPhotoSelected == false {
            // Sorted by like count
                moveVC.objectIdTemp = objectIdLikes[selectedCellIndex!.row]
            } else {
                
                moveVC.objectIdTemp = myObjectId[selectedCellIndex!.row]
            }
        
        }  
    }
    
    //--------------- Camera ---------------
    //initialize camera
    func takePhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Button capture")

            //primary delegate for the picker
            picker.delegate = self
            picker.sourceType = .Camera
            picker.mediaTypes = [kUTTypeImage]
            picker.allowsEditing = false
            self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0)
            self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, 71.0), 1.333333, 1.333333)
            // resize
            if (zoomImage.camera) {
                var screenBounds: CGSize = UIScreen.mainScreen().bounds.size
                var cameraAspectRatio: CGFloat = 4.0/3.0
                var cameraViewHeight = screenBounds.width * cameraAspectRatio
                var scale = screenBounds.height / cameraViewHeight
                picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - cameraViewHeight) / 2.0)
                picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale)
                //self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 1.0, 1.0)
                self.zoomImage.camera = false
            }
            
            // custom camera overlayview
            picker.showsCameraControls = false
            NSBundle.mainBundle().loadNibNamed("OverlayView", owner:self, options:nil)
            self.overlayView!.frame = picker.cameraOverlayView!.frame
            picker.cameraOverlayView = self.overlayView
            self.overlayView = nil
            
            self.presentViewController(picker, animated:true, completion:{})
            setLastPhoto()
            updateThumbnail()

            newMedia = true
        } else {
            if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                var picker = UIImagePickerController()
                picker.delegate = self;
                picker.sourceType = .PhotoLibrary
                picker.mediaTypes = [kUTTypeImage]
                picker.allowsEditing = false
                
                self.presentViewController(picker, animated:true, completion:{})
                setLastPhoto()
                updateThumbnail()

                newMedia = false
            }
        }

        
    }
    
    func imageFixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.Up) {
            return img;
        }

        var transform:CGAffineTransform = CGAffineTransformIdentity
        
        if (img.imageOrientation == UIImageOrientation.Down
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if (img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, 0, img.size.height);
                transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
        }
        
        if (img.imageOrientation == UIImageOrientation.UpMirrored
            || img.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, img.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
        }
         //var ctx:CGContextRef = CGBitmapContextCreate(<#data: UnsafeMutablePointer<Void>#>, <#width: Int#>, <#height: Int#>, <#bitsPerComponent: Int#>, <#bytesPerRow: Int#>, <#space: CGColorSpace!#>, <#bitmapInfo: CGBitmapInfo#>)

        var ctx:CGContextRef = CGBitmapContextCreate(nil, Int(img.size.width), Int(img.size.height), CGImageGetBitsPerComponent(img.CGImage), 0, CGImageGetColorSpace(img.CGImage), CGImageGetBitmapInfo(img.CGImage))
        
        CGContextConcatCTM(ctx, transform)
        
        if (img.imageOrientation == UIImageOrientation.Left
            || img.imageOrientation == UIImageOrientation.LeftMirrored
            || img.imageOrientation == UIImageOrientation.Right
            || img.imageOrientation == UIImageOrientation.RightMirrored
            ) {
                
                CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage)
        } else {
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage)
        }
        
        var cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)
        var imgEnd:UIImage = UIImage(CGImage: cgimg)!
        
        return imgEnd
    }
    
    func saveImageAlert()
    {
        var alert:UIAlertView = UIAlertView()
        alert.title = "Saved!"
        alert.message = "Saved to Camera Roll"
        alert.delegate = self
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    @IBAction func loadFromLibrary(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.sourceType =
            UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageViewContent = image
        picker.dismissViewControllerAnimated(true, completion: nil)
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        //Retake and crop options------------------------------------------------------------------------
        let previewViewController = PreviewViewController(nibName: "PreviewViewController", bundle: nil);
        previewViewController.cropCompletionHandler = {
            self.imageViewContent = $0!
            previewViewController.dismissViewControllerAnimated(true, completion: nil)
            //self.dismissViewControllerAnimated(true, completion: nil);
        }
        previewViewController.cancelCompletionHandler = {
            //retake image
            //self.dismissViewControllerAnimated(true, completion: nil)
            
            self.presentViewController(picker, animated:true, completion:{})
            self.setLastPhoto()
            self.updateThumbnail()
            self.flashButton.hidden = false
            
        }
        if self.picker.cameraDevice == UIImagePickerControllerCameraDevice.Front{
            previewViewController.imageToCrop = UIImage(CGImage: imageViewContent.CGImage, scale: 1.0, orientation: .LeftMirrored)
        }
        else{
            previewViewController.imageToCrop = imageViewContent
        }
        
        previewViewController.eventId = self.eventId
        previewViewController.eventTitle = self.eventTitle
        
        self.presentViewController(previewViewController, animated: true, completion: nil);
        //UIImageWriteToSavedPhotosAlbum(previewViewController.imageToCrop, nil, nil, nil)
        //ensure image is cropped to a square
        //self.imageView.image = image
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
        
        return image
    }
    
    func testCalled()
    {
        
        let sourceType = UIImagePickerControllerSourceType.Camera
        if (!UIImagePickerController.isSourceTypeAvailable(sourceType))
        {
            var alert:UIAlertView = UIAlertView()
            alert.title = "Cannot access camera!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        
        let frontCamera = UIImagePickerControllerCameraDevice.Front
        let rearCamera = UIImagePickerControllerCameraDevice.Rear
        if (!UIImagePickerController.isCameraDeviceAvailable(frontCamera))
        {
            var alert:UIAlertView = UIAlertView()
            alert.title = "Cannot access front-facing camera!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        if (!UIImagePickerController.isCameraDeviceAvailable(rearCamera))
        {
            var alert:UIAlertView = UIAlertView()
            alert.title = "Cannot access rear-facing camera!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    @IBAction func reverseCamera(sender: UIButton) {
        //TO-DO: add transition when reversed
        if self.picker.cameraDevice == UIImagePickerControllerCameraDevice.Front{
            //self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0)
            //self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, 71.0), 1.333333, 1.333333)

                var screenBounds: CGSize = UIScreen.mainScreen().bounds.size
                var cameraAspectRatio: CGFloat = 4.0/3.0
                var cameraViewHeight = screenBounds.width * cameraAspectRatio
                var scale = screenBounds.height / cameraViewHeight
                picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - cameraViewHeight) / 2.0)
                picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale)
                //self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 1.0, 1.0)
                self.zoomImage.camera = false
            
            
            UIView.transitionWithView(self.picker.view, duration: 1.0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.TransitionCurlDown , animations: { () -> Void in
                self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
                }, completion: nil)
            //self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear

            self.flashButton.hidden = false
        }else{
            
            //----------------------------------------------------------------------------
            self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, -5.0)
            //self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, -5.0), 1.333333, 1.333333)
            self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 1.0, 1.0)

            // resize
            if (zoomImage.camera) {
                //self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 0.7, 0.7);
                self.zoomImage.camera = false
            }
            //----------------------------------------------------------------------------

            UIView.transitionWithView(self.picker.view, duration: 1.0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.TransitionCurlDown , animations: { () -> Void in
                self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
                }, completion: nil)
            //self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Front

            self.flashButton.hidden = true
        }
    }
    
    @IBAction func showCameraRoll(sender: UIButton) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        controller.mediaTypes = [kUTTypeImage]
        controller.delegate = self
        self.presentViewController(controller, animated:true, completion:nil)
        
    }
    
    @IBAction func capture(sender: UIButton) {
        picker.takePicture()
        updateThumbnail()
    }
    
    func updateThumbnail(){
        thumbnailButton.setBackgroundImage(image, forState: .Normal)
        //thumbnailButton.setImage(image, forState: .Normal)
        thumbnailButton.layer.borderColor = UIColor.blueColor().CGColor
        thumbnailButton.layer.borderWidth=1.0
        
    }
    @IBAction func toggleTorch(sender: UIButton) {
        //TO-DO: add indication of toggle (image change)
        if self.picker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.On{
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
            //self.flashButton.setImage(flashOff, forState: .Normal)

            var alert:UIAlertView = UIAlertView()
            alert.title = "Flash off!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }else{
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
            //self.flashButton.setImage(flashOn, forState: .Normal)
            var alert:UIAlertView = UIAlertView()
            alert.title = "Flash on!"
            alert.message = " "
            alert.delegate = self
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    //TO-DO: restriction through geotagged image
    func setLastPhoto(){
        var fetchOptions: PHFetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        
        if (fetchResult.lastObject != nil) {
            
            var lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
            
            var sizeIM = CGSizeMake(50,50)
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: sizeIM , contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.thumbnailButton.setBackgroundImage(result, forState: .Normal)
                self.thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
                self.thumbnailButton.layer.borderWidth=1.0
                self.thumbnailButton.layer.cornerRadius = 5
            }
            
        }
    }
//    @IBAction func openSettings(sender: UIButton) {
//        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
//    }
    
    @IBAction func cancelCamera(sender: AnyObject) {
        picker.dismissViewControllerAnimated(true, completion: nil)

    }

    func captureTest(sender : UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Button capture")
            
            testCamera.delegate = self
            testCamera.sourceType = UIImagePickerControllerSourceType.Camera;
            testCamera.mediaTypes = [kUTTypeImage]
            testCamera.allowsEditing = false
            
            self.presentViewController(testCamera, animated: true, completion: nil)
        }
    }
    
    //TO-DO: UIDeviceOrientationIsLandscape --> then rotate image
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    

}
