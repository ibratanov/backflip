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

class albumViewController: UICollectionViewController {
    
    //variable for segue
    var images = [UIImage]()
    
    //tuple for sorting
    var imageFilesTemp : [(image: PFFile , likes: Int , id: String, title: String, date: NSDate)] = []
    var imageFilesLikes = [PFFile]()
    var objectIDTime = [String]()
    var datesTime = [NSDate]()
    var titlesTime = [String]()
    
    //arrays for time sort
    var imageFilesTime = [PFFile]()
    var objectIDs = [String]()
    var dates = [NSDate]()
    var titles = [String]()
    
    
    var sorted = false
    var sorted1 = true

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        // Button to switch sorting options
        let viewChangeButton = UIButton(frame: CGRectMake(0, 0, 50, 50))
        //viewChangeButton.center = self.view.center
        viewChangeButton.center.y = self.view.bounds.height - 50
        viewChangeButton.backgroundColor = UIColor.whiteColor()
        viewChangeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        viewChangeButton.setTitle("Sort", forState: UIControlState.Normal)
        viewChangeButton.addTarget(self, action: "sortButton", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(viewChangeButton)
        self.view.bringSubviewToFront(viewChangeButton)
        
        // Button to switch between feed view and album view
        let feedChangeButton = UIButton(frame: CGRectMake(250,250,50,50))
        feedChangeButton.center.y = self.view.bounds.height - 50
        feedChangeButton.backgroundColor = UIColor.whiteColor()
        feedChangeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        feedChangeButton.setTitle("View", forState: UIControlState.Normal)
        feedChangeButton.addTarget(self, action:"viewChange", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(feedChangeButton)
        self.view.bringSubviewToFront(feedChangeButton)
        

        
        var getUploadedImages = PFQuery(className: "Post")
        
        getUploadedImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                for object in objects! {
                    
                    // Creates tuple for easier sorting
                    let tup = (image: object["imageFile"] as! PFFile, likes: object["likeCount"] as! Int, id: object.objectId!! as String, title: object["Title"] as! String ,  date: object["timeStamp"] as! NSDate)
                    
                    self.imageFilesTemp.append(tup)
    
                    // Fills arrays for images sorted by time
                    self.imageFilesTime.append(object["imageFile"] as! PFFile)
                    self.objectIDs.append(object.objectId! as String!)
                    self.titles.append(object["Title"] as! String)
                    self.dates.append(object["timeStamp"] as! NSDate)
                    
                
                    self.collectionView?.reloadData()
                    
                }
                
                // Sort tuple of images,likes, and fill new array with photos in order of likes
                self.imageFilesTemp.sort{ $0.likes > $1.likes}
                
                for (image,likes, id, title, date) in self.imageFilesTemp {
                    
                    self.imageFilesLikes.append(image)
                    self.objectIDTime.append(id)
                    self.titlesTime.append(title)
                    self.datesTime.append(date)
    
                }
                
            } else {
                
                println(error)
                
            }
        }
        
    }
    
    func sortButton() {
        
        // Change boolean, reload data, to sort images
        if sorted == true {
        
        sorted = false
            
        self.collectionView?.reloadData()
        
        } else {
        
        sorted = true

        self.collectionView?.reloadData()
            
        }
        
    func viewChange() {
        
        let storyboard = UIStoryboard(name: "albumView", bundle: nil)
        let newVC = storyboard.instantiateViewControllerWithIdentifier("feedView") as? feedViewController
        self.presentViewController(newVC!, animated: true, completion: nil)
        
  
        
        }
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        let albumCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! albumViewCell
    
        // Configure the cell

        if sorted == false {
            
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
    
        return albumCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "toFull" {
            
            var moveVC: fullScreenViewController = segue.destinationViewController as! fullScreenViewController
            var selectedCellIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
            
            // Sorted by time
            if self.sorted == false {
                
                moveVC.cellImage = images[selectedCellIndex!.row]
                moveVC.objectIdTemp = objectIDs[selectedCellIndex!.row]
                moveVC.tempDate = dates[selectedCellIndex!.row]
                moveVC.tempTitle = titles[selectedCellIndex!.row]
                
            } else {
            // Sorted by like count
                moveVC.cellImage = images[selectedCellIndex!.row]
                moveVC.objectIdTemp = objectIDTime[selectedCellIndex!.row]
                moveVC.tempDate = datesTime[selectedCellIndex!.row]
                moveVC.tempTitle = titlesTime[selectedCellIndex!.row]
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
