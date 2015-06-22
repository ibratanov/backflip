//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Zachary Lefevre on 2015-05-11.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import DigitsKit

class EventTableViewController: UITableViewController {
    
    @IBAction func logoutButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
    }
    
    func addEvent(sender: AnyObject) {
        performSegueWithIdentifier("addEventSegue", sender: nil)
    }
    
    var imageList: [PFFile] = []
    var events: [String] = []
    
    var eventWithPhotos = [String:[PFFile]]()
    var eventWithIds = [String:[PFFile]]()
    
    var eventObjs: [PFObject] = []
    
    var logoutButton = UIImage(named: "settings-icon") as UIImage!
    var addButton = UIImage(named: "add-icon") as UIImage!

    
    var eventId: [String] = []
    var venues: [String] = []
    
//    Enable UI Navigation Itemr
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir-Medium",size: 18)!]
        self.tableView.reloadData()
        
        updateEvents()
    }
    
    override func viewDidLoad() {
        
    }
    
    func displayAlertLogout(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .Default, handler: { action in
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
            
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            
            self.performSegueWithIdentifier("logoutEventView", sender: self)
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func updateEvents(){
  
        let query = PFUser.query()
        query?.includeKey("savedEvents")
        query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
            
            self.eventObjs.removeAll(keepCapacity: true)
            self.eventObjs = object!.objectForKey("savedEvents") as! [PFObject]
            
            self.eventObjs = sorted(self.eventObjs, { $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending })
            
            for event in self.eventObjs {
                let relation = event.relationForKey("photos")
                let query = relation.query()
                query!.limit = 4
                var photos = query!.findObjects() as! [PFObject]
                var thumbnails: [PFFile] = []
                for photo in photos {
                    thumbnails.append(photo["thumbnail"] as! PFFile)
                }
                self.eventWithPhotos[event.objectId!] = thumbnails
                self.eventWithIds[event.objectId!] = thumbnails
            }
            
            self.tableView.reloadData()

            
        })
        
    }
    
    func updatePhotosForEvent(objectId: String) -> [PFFile] {
        
        var query = PFQuery(className: "Event")
        query.whereKey("objectId", equalTo: objectId)
        
        var photoListForEvent: [PFFile] = []
        
        var object = query.findObjects()?.first as! PFObject
        
        var photos = object["photos"] as! PFRelation
        
        var photoList = photos.query()?.findObjects() as! [PFObject]
        
        for photo in photoList {
            var image = photo["image"] as! PFFile
            photoListForEvent.append(image)
        }
        
        return photoListForEvent
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(self.eventWithPhotos.keys).count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! EventTableViewCell
        tableCell.selectionStyle = UITableViewCellSelectionStyle.None
        var key : String = Array(self.eventWithPhotos.keys)[indexPath.row]
        
        var ev : PFObject = eventObjs[indexPath.row]
        var evName : String = ev["eventName"] as! String
        var evVenue : String = ev["venue"] as! String
        
        var listPhotos = self.eventWithPhotos[ev.objectId!] as [PFFile]!
        var underlineColor : UIColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
        tableCell.eventName.text = evName
        tableCell.eventLocation.text = evVenue
        
        if listPhotos.count == 0 {
            tableCell.imageOne!.image = UIImage ()
            tableCell.imageOne.backgroundColor = underlineColor
            
            tableCell.imageTwo!.image = UIImage ()
            tableCell.imageTwo.backgroundColor = underlineColor
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageThree.backgroundColor = underlineColor
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor

            return tableCell
        }
        
        if listPhotos.count == 1 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            tableCell.imageTwo!.image = UIImage ()
            tableCell.imageTwo.backgroundColor = underlineColor
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageThree.backgroundColor = underlineColor
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor
            
            return tableCell
        }
        
        if listPhotos.count == 2 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            var imageData2 = listPhotos[1].getData()
            tableCell.imageTwo!.image = UIImage (data: imageData2!)
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageThree.backgroundColor = underlineColor
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor
            
            return tableCell
        }
        
        if listPhotos.count == 3 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            var imageData2 = listPhotos[1].getData()
            tableCell.imageTwo!.image = UIImage (data: imageData2!)
            
            var imageData3 = listPhotos[2].getData()
            tableCell.imageThree!.image = UIImage (data: imageData3!)
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor
            
            return tableCell
        }
        
        if listPhotos.count >= 4 {
            var imageData1 = listPhotos[0].getData()
            tableCell.imageOne!.image = UIImage (data: imageData1!)
            
            var imageData2 = listPhotos[1].getData()
            tableCell.imageTwo!.image = UIImage (data: imageData2!)
            
            var imageData3 = listPhotos[2].getData()
            tableCell.imageThree!.image = UIImage (data: imageData3!)
            
            var imageData4 = listPhotos[3].getData()
            tableCell.imageFour!.image = UIImage (data: imageData4!)

            return tableCell
        }
        
        return tableCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toAlbum" {
            
            let moveVC = segue.destinationViewController as! AlbumViewController
            
            if let selectedPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                var event = eventObjs[selectedPath.row]
                moveVC.eventId = event.objectId
                moveVC.eventTitle = event["eventName"] as? String
            }
        }
    }

}
