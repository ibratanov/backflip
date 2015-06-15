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


let reuseIdentifier = "albumCell"

class AlbumViewController: UICollectionViewController,UIImagePickerControllerDelegate,
    UINavigationControllerDelegate{
    
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
    
    // Title passed from previous VC
    var eventId : String?
    
    // Variable for storing PFFile as image, pass through segue
    var images = [UIImage]()
    var postLogo = UIImage(named: "liked.png") as UIImage!
    var goBack = UIImage(named: "goto-eventhistory-icon") as UIImage!
    var share = UIImage(named: "share-icon") as UIImage!
//    var bgImage = UIImage(named: "goto-camera-background") as UIImage!
//    var cam = UIImage(named:"goto-camera") as UIImage!
    var newCam = UIImage(named:"goto-camera-full") as UIImage!

    
    // Tuple for sorting
    var imageFilesTemp : [(image: PFFile , likes: Int , id: String,date: NSDate)] = []
    
    // Arrays for like sort
    var imageFilesLikes = [PFFile]()
    var objectIdLikes = [String]()
    var datesLikes = [NSDate]()
    
    // Arrays for time sort
    var imageFilesTime = [PFFile]()
    var objectIdTime = [String]()
    var datesTime = [NSDate]()
    
    // Checker for sort button. Sort in chronological order by default.
    var sortedByLikes = false
    
    // Display alert function for when an album timer is going to run out
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func viewChanger (sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            
            // Rating
            case 0 :    sortedByLikes = true
                        updatePhotos()
                        self.collectionView?.reloadData()
            
            // Time
            case 1:     sortedByLikes = false
                        updatePhotos()
                        self.collectionView?.reloadData()
            
            // My Photos
            case 2 :    println("hi")
            
            
            default:    updateAlbum()
            
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {

        // Initialize segmented control button
        let items = ["RATING", "NEWEST", "MY PHOTOS"]
        let segC = UISegmentedControl(items: items)
        segC.selectedSegmentIndex = 0
        
        // Defines where seg control is positioned
        let frame: CGRect = UIScreen.mainScreen().bounds
        println(frame)
        let screenWidth = frame.width
        let screenHeight = frame.height
        var superCenter = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
        segC.frame = CGRectMake(CGRectGetMinX(frame),100,screenWidth,40)
        
        // Set characteristics of segmented controller
        var backColor : UIColor = UIColor.blackColor()
        var titleFont : UIFont = UIFont(name: "Avenir", size: 12.0)!
        var textColor : UIColor = UIColor.whiteColor()
        var underline  =  NSUnderlineStyle.StyleSingle.rawValue
        var blue : UIColor = UIColor.blueColor()
        
        
        // Attributes for non selected segments
        var segAttributes = [
            
            NSForegroundColorAttributeName : backColor,

            NSFontAttributeName : titleFont,
            
            NSBackgroundColorAttributeName : textColor
        ]

        // Attributes for when segment is selected
        var segAttributes1 = [
            
            NSForegroundColorAttributeName : backColor,
            
            NSFontAttributeName : titleFont,
            
            NSUnderlineStyleAttributeName : underline,
            
            NSUnderlineColorAttributeName : blue
            
        ]
        
        // Implement the above attributes on our segmented control
        segC.setTitleTextAttributes(segAttributes as [NSObject:AnyObject],forState: UIControlState.Normal)
        segC.setTitleTextAttributes(segAttributes1 as [NSObject:AnyObject], forState: UIControlState.Selected)
        
        // Implement base colors on our segmented control
        segC.tintColor = UIColor.whiteColor()
        segC.backgroundColor = UIColor.whiteColor()
        
        // Add targets, initialize segmented control
        segC.addTarget(self, action: "viewChanger:", forControlEvents: .ValueChanged)
        self.view.addSubview(segC)
        
        
        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 100))
        navBar.backgroundColor =  UIColor.whiteColor()
        
        // Removes faint line under nav bar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
        navBarItem.title = "EVENT TITLE"
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "avenir", size: 30)!]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let back = UIButton.buttonWithType(.System) as! UIButton
        back.setBackgroundImage(goBack, forState: .Normal)
        back.backgroundColor = UIColor.whiteColor()
        back.frame = CGRectMake(10, 65, 25, 25)
        back.addTarget(self, action: "seg", forControlEvents: .TouchUpInside)
        navBar.addSubview(back)
        
        // Right nav bar button item
        let shareAlbum = UIButton.buttonWithType(.System) as! UIButton
        shareAlbum.setBackgroundImage(share, forState: .Normal)
        shareAlbum.frame = CGRectMake(285,65,25,25)
        shareAlbum.addTarget(self, action: "print", forControlEvents: .TouchUpInside)
        navBar.addSubview(shareAlbum)

        self.view.addSubview(navBar)

        // Post photo button
        let postPhoto = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        postPhoto.setImage(newCam, forState: .Normal)
        postPhoto.frame = CGRectMake((self.view.frame.size.width/2)-40, self.view.frame.height-95, 80, 80)
        postPhoto.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(postPhoto)
        
        
    }
    
    func print(){
        
        println("test")
        
    }
    
    func seg() {
        
        //self.performSegueWithIdentifier("backButton", sender: self)
        self.navigationController?.popViewControllerAnimated(true)
        
    }


    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        
        // Set VC color
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        
        // Pushes collection view down, higher value pushes collection view downwards
        collectionView?.contentInset = UIEdgeInsetsMake(150.0,0.0,0.0,0.0)
        self.automaticallyAdjustsScrollViewInsets = false
 
        // Pull down to refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refresher)

        
        // Initialize date comparison components
        let currentTime = NSDate()
        let cal = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.hour = 48
        let components2 = NSDateComponents()
        components2.hour = 24
        
        var eventQuery = PFQuery(className: "Event")
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
        
        updateAlbum()

    }
    
    func refresh() {
        
        updatePhotos()
        self.refresher.endRefreshing()
        
    }
    
    func sortButton() {
        
        // Change boolean, reload data to sort images
        sortedByLikes == true
        
        self.collectionView?.reloadData()
    }
    
    
    func updateAlbum() {
        
        var getUploadedImages = PFQuery(className: "Photo")
        
        // Parse query limit default is 100 objects
        getUploadedImages.limit = 1000
        
        getUploadedImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                for object in objects! {
                    
                    let tup = (image: object["image"] as! PFFile, likes: object["upvoteCount"] as! Int, id: object.objectId!! as String,date: object.createdAt!! as NSDate)
                    
                    
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
                
                // Sort tuple of images,
                self.imageFilesTemp.sort{ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
                
                for (image, likes, id, date) in self.imageFilesTemp {
                    
                    self.imageFilesTime.append(image)
                    self.objectIdTime.append(id)
                    self.datesTime.append(date)
                    
                }
                
            } else {
                
                println(error)
                
            }
            
            //self.collectionView?.reloadData()
            //self.refresher.endRefreshing()
        }
    }
    
    
    
    
    
    // TODO: Smart loading of photos - only reload photos which are new/were modified
    func updatePhotos() {
        self.imageFilesTemp.removeAll(keepCapacity: true)
        
        self.imageFilesLikes.removeAll(keepCapacity: true)
        self.objectIdLikes.removeAll(keepCapacity: true)
        self.datesLikes.removeAll(keepCapacity: true)
        
        self.imageFilesTime.removeAll(keepCapacity: true)
        self.objectIdTime.removeAll(keepCapacity: true)
        self.datesTime.removeAll(keepCapacity: true)
        
        self.images.removeAll(keepCapacity: true)
        
        // Load information from parse db
        var getUploadedImages = PFQuery(className: "Photo")
        getUploadedImages.limit = 1000
        getUploadedImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                for object in objects! {
                    
                    let tup = (image: object["image"] as! PFFile, likes: object["upvoteCount"] as! Int, id: object.objectId!! as String,date: object.createdAt!! as NSDate)
                    
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
                
                // Sort tuple of images,
                self.imageFilesTemp.sort{ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending}
                
                for (image, likes, id, date) in self.imageFilesTemp {
                    
                    self.imageFilesTime.append(image)
                    self.objectIdTime.append(id)
                    self.datesTime.append(date)
                    
                }
                
            } else {
                
                println(error)
                
            }
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
        return imageFilesTime.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let albumCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumViewCell

        if sortedByLikes == false {
            
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
        } else {
            
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
    
       }
        albumCell.layer.shouldRasterize = true
        albumCell.layer.rasterizationScale = UIScreen.mainScreen().scale    
        return albumCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "toFull" {
            
            var moveVC: FullScreenViewController = segue.destinationViewController as! FullScreenViewController
            var selectedCellIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
            
            // Sorted by time (from newest to oldest)
            if self.sortedByLikes == false {

                moveVC.objectIdTemp = objectIdTime[selectedCellIndex!.row]
                
            } else {
            // Sorted by like count
                moveVC.objectIdTemp = objectIdLikes[selectedCellIndex!.row]
            }
        
        }  
    }
    
    //--------------------------------Camera-----------------------------------------------------
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
                self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 1.5, 1.5);
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
                newMedia = false
            }
        }
        
        
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
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        image =
            info[UIImagePickerControllerOriginalImage] as! UIImage
        //set image cropped square
        
        self.imageViewContent = cropToSquare(image:image)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
            self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            self.flashButton.hidden = false
        }else{
            self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
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
            
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: self.imageViewContent.size, contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                
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
