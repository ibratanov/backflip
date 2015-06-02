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
    
    
    var images = [UIImage]()
    var imageFilesTemp : [(image: PFFile , likes: Int)] = []
    var imageFilesLikes = [PFFile]()
    var imageFilesTime = [PFFile]()
    var objectIDs = [String]()
    var dates = [NSDate]()
    var titles = [String]()
    var sorted = true

    @IBAction func sortButton(sender: AnyObject) {
    
        if sorted == true{
            
            sorted = false
            //sortButton.setTitle("Likes", forState:UIControlState.Normal)
            
        } else {
            
            sorted = true
        }
 
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        
        var getUploadedImages = PFQuery(className: "Post")
        
        getUploadedImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                
                for object in objects! {
                    
                    self.imageFilesTemp.append(image: object["imageFile"] as! PFFile,likes: object["likeCount"] as! Int)
                    self.imageFilesTime.append(object["imageFile"] as! PFFile)
                    self.objectIDs.append(object.objectId! as String!)
                    self.titles.append(object["Title"] as! String)
                    self.dates.append(object["timeStamp"] as! NSDate)
                    
                    //self.imageFiles1.sort({$0.likes > $1.likes})
                
                    self.collectionView?.reloadData()
                    
                }
                
                // Sort tuple of images,likes, and fill new array with photos in order of likes
                self.imageFilesTemp.sort{ $0.likes > $1.likes}
                
                for (image,likes) in self.imageFilesTemp {
                    
                    self.imageFilesLikes.append(image)
    
                }
                
                dump(self.imageFilesLikes)
                dump(self.imageFilesTime)
                
            } else {
                
                println(error)
                
            }
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
        

        /*if sorted == false {
            
            // Default, fill the cells with photos sorted by time
        
            imageFilesTime[indexPath.row].getDataInBackgroundWithBlock { (imageData, error) -> Void in
                
                if error == nil {
                    
                    let image = UIImage (data: imageData!)
                    self.images.append(image!)
                    
                    albumCell.imageView.image = image
                    
                } else {
                    
                    println(error)
                    
                }
                
                //self.collectionView?.reloadData()
                
            }
        } else { */
            
            // Fill the cells with the sorted photos by likes
            println(self.imageFilesLikes[indexPath.row])
            imageFilesLikes[indexPath.row].getDataInBackgroundWithBlock { (imageD,error) -> Void in
         
                if error == nil {
                    
                    let image = UIImage (data: imageD!)
                    self.images.append(image!)
                    var id = imageD.objectId as! String
                    
                    albumCell.imageView.image = image
                    
                } else {
                    
                    println(error)
                    
                }
                
                //self.collectionView?.reloadData()
                
            }
    
    //}
    
        return albumCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "toFull" {
            
            var moveVC: fullScreenViewController = segue.destinationViewController as! fullScreenViewController
            var selectedCellIndex = self.collectionView?.indexPathForCell(sender as! UICollectionViewCell)
            

            moveVC.cellImage = images[selectedCellIndex!.row]
            moveVC.objectIdTemp = objectIDs[selectedCellIndex!.row]
            moveVC.tempDate = dates[selectedCellIndex!.row]
            moveVC.tempTitle = titles[selectedCellIndex!.row]
        
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
