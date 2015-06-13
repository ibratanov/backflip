//
//  albumViewController.swift
//  ParseStarterProject
//
//  Created by Jonathan Arlauskas on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

let reuseIdentifier = "albumCell"

class AlbumViewController: UICollectionViewController {
    
    var refresher: UIRefreshControl!
    
    // Title passed from previous VC
    var eventId : String?
    
    // Variable for storing PFFile as image, pass through segue
    var images = [UIImage]()
    var postLogo = UIImage(named: "liked.png") as UIImage!
    var goBack = UIImage(named: "goto-eventhistory-icon") as UIImage!
    var share = UIImage(named: "share-icon") as UIImage!
    var bgImage = UIImage(named: "goto-camera-background") as UIImage!
    var cam = UIImage(named:"goto-camera") as UIImage!

    
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

        // Creates the plain white bar on the bottom of the screen
        let bottomBar = UIView(frame: CGRectMake(0, 455, self.view.frame.size.width, 125))
        bottomBar.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(bottomBar)
        
        // Post a photo button, a subview of the bottom bar
        let postPhoto = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            postPhoto.setBackgroundImage(bgImage, forState: .Normal)
            postPhoto.setImage(cam, forState: .Normal)
            postPhoto.frame = CGRectMake(0, 0, 80, 80)
            postPhoto.center = CGPointMake(bottomBar.frame.size.width/2, bottomBar.frame.size.height/2)
            postPhoto.addTarget(self, action: "print", forControlEvents: UIControlEvents.TouchUpInside)
            bottomBar.addSubview(postPhoto)
            bottomBar.bringSubviewToFront(postPhoto)
        
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
