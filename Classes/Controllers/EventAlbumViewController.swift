//
//  EventAlbumViewController.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-07.
//  Copyright (c) 2015 Backflip. All rights reserved.
//


import Parse
import Photos
import MessageUI
import Foundation


class EventAlbumViewController : UICollectionViewController, MWPhotoBrowserDelegate
{
	
	//-------------------------------------
	// MARK: Global Variables
	//-------------------------------------
	
	var eventId : String?
	var eventTitle : String?
	var event : Event?
	
	let CELL_REUSE_IDENTIFIER = "album-cell"
	
	var orginalContent : [Image] = []
	var collectionContent : [Image] = []
	
	var photoBrowser : MWPhotoBrowser?
	
	var likeButton : UIBarButtonItem?
	var likeLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 100, 21))
	
	
	@IBOutlet weak var segmentedControl : UISegmentedControl!
	let spinner : UIActivityIndicatorView = UIActivityIndicatorView()
	let refreshControl : UIRefreshControl = UIRefreshControl.new()
	
	
	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		UIApplication.sharedApplication().statusBarHidden = false
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.title = self.eventTitle
		
		// Hide the "leave" button when pushed from event history
		let currentEventId = NSUserDefaults.standardUserDefaults().valueForKey("checkin_event_id") as? String
		if (currentEventId == self.eventId) {
			self.navigationController?.setViewControllers([self], animated: false)
		} else {
			self.navigationItem.leftBarButtonItem = nil
		}
		
		updateData()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoUploaded", name: "camera-photo-uploaded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "flagPhoto:", name: "BFImageReportActivitySelected", object: nil)
		
		refreshControl.tintColor = UIColor(red:0,  green:0.588,  blue:0.533, alpha:1)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: "updateData", forControlEvents: .ValueChanged)
		self.collectionView!.addSubview(refreshControl)
		
		// Layout -  Only run on the main thread
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.collectionView?.contentInset = UIEdgeInsetsMake(0.0,0.0,72.0,0.0)
			
			let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
			flow.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
			flow.itemSize = CGSizeMake((self.view.frame.size.width/3)-1, (self.view.frame.size.width/3)-1);
			flow.minimumInteritemSpacing = 1;
			flow.minimumLineSpacing = 1;
		})
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle
	{
		return .LightContent
	}
	
	
	
	//-------------------------------------
	// MARK: Actions
	//-------------------------------------
	
	
	@IBAction func leaveEvent()
	{
		var alertController = UIAlertController(title: "Leave Event", message: "Are you sure you want to leave? This event will be moved to your event history.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Leave", style: .Destructive, handler: { (alertAction) -> Void in
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
			
			
			let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			let checkinViewController = storyboard.instantiateViewControllerWithIdentifier("CheckinViewController") as! CheckinViewController
			self.navigationController?.setViewControllers([checkinViewController], animated: false)

		}))
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	
	func photoUploaded()
	{
		self.updateData()
	}
	
	
	//-------------------------------------
	// MARK: BWPhotoBrowserDelegate
	//-------------------------------------
	
	func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt
	{
		return UInt(collectionContent.count)
	}
	
	
	func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol!
	{
		if (collectionContent.count < Int(index)) {
			return nil;
		}
		
		let file = collectionContent[Int(index)]
		let photo = MWPhoto(URL: NSURL(string: file.image.url!))
		return photo
	}
	
	func photoBrowser(photoBrowser: MWPhotoBrowser!, didDisplayPhotoAtIndex index: UInt)
	{
		let image = self.collectionContent[Int(index)]
		likeLabel.text = NSString(format: "%i likes", image.likes) as String
		
		let liked = contains(image.likedBy, PFUser.currentUser()!.username!)
		if (liked) {
			likeButton?.image = UIImage(named: "heart-icon-filled")
		} else {
			likeButton?.image = UIImage(named: "heart-icon-empty")
		}
	}
	
	
	//-------------------------------------
	// MARK: UICollectionViewDelegate
	//-------------------------------------
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return (1 + Int(collectionContent.count))
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! AlbumViewCell
		
		if (indexPath.row == 0) {
			cell.imageView.image = UIImage(named: "album-add-photo")
			cell.imageView.image!.imageWithRenderingMode(.AlwaysTemplate)
			cell.imageView.tintColor = UIColor.grayColor()
		} else if (self.collectionContent.count >= indexPath.row) {
			
			var file : PFFile = collectionContent[Int(indexPath.row)-1].thumbnail
			// cell.imageView.setImageWithURL(NSURL(string: file.url!))
			
		}
		
		cell.layer.shouldRasterize = true
		cell.layer.rasterizationScale = UIScreen.mainScreen().scale
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row == 0) {
			
			var event = Event()
			let tabBarDelegate = BFTabBarControllerDelegate.sharedDelegate
			event.objectId = self.eventId
			event.name = self.eventTitle
			tabBarDelegate.displayCamera(event)
			
		} else {
		
			photoBrowser = MWPhotoBrowser(delegate: self)
			photoBrowser?.alwaysShowControls = false
			photoBrowser?.displayActionButton = false
		
			// Our own custom share button
			let shareBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "sharePhoto")
			shareBarButton.image = UIImage(named: "more-icon")
		
		
			// Toolbar items
			let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
			let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
			fixedSpace.width = 8
		
			likeButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "likePhoto")
			likeButton?.image = UIImage(named: "heart-icon-empty")
		
			likeLabel.font = UIFont(name: "Avenir-Medium", size: 16)
			likeLabel.textColor = UIColor.whiteColor()
			likeLabel.backgroundColor = UIColor.clearColor()
		
			var likeLabelButton = UIBarButtonItem(customView: likeLabel)
		
			photoBrowser?.toolbar?.items = [fixedSpace, likeButton!, fixedSpace, likeLabelButton, flexSpace, shareBarButton]
		
			photoBrowser?.setCurrentPhotoIndex(UInt(indexPath.row)-1)
		
			self.navigationController?.pushViewController(photoBrowser!, animated: true)
		}
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
	{
		var supplementaryView : AnyObject! = nil
		if kind == UICollectionElementKindSectionHeader {
			supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header-view", forIndexPath: indexPath)
			
			self.segmentedControl = supplementaryView.subviews[0] as! UISegmentedControl
		} else if kind == UICollectionElementKindSectionFooter {
			supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer-view", forIndexPath: indexPath)
		}
		
		return supplementaryView as! UICollectionReusableView
	}
	
	
	//-------------------------------------
	// MARK: Segemented Control
	//-------------------------------------
	
	@IBAction func segementedControlValueChanged(sender: AnyObject)
	{
		if (self.orginalContent.count < 1) {
			return
		}
		
		let segementedControl = sender as! UISegmentedControl
		var content = self.orginalContent
		
		self.collectionContent.removeAll(keepCapacity: true)
		self.collectionView?.reloadData()
		
		if segementedControl.selectedSegmentIndex == 0 {
			content.sort{ $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending }
		} else if segementedControl.selectedSegmentIndex == 1 {
			content.sort{ $0.likes > $1.likes }
		} else if segementedControl.selectedSegmentIndex == 2 {
			content.removeAll(keepCapacity: true)
			for (var i = 0; i < self.orginalContent.count; i++) {
				let image = self.orginalContent[i]
				let liked = contains(image.likedBy, PFUser.currentUser()!.username!)
				if (liked) {
					content.append(image)
				}
			}
			
		}
		
		self.collectionContent = content

		let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			self.collectionView?.performBatchUpdates({ () -> Void in
				self.collectionView?.reloadData()
			}, completion: nil)
		})
	}
	
	
	//-------------------------------------
	// MARK: Sharing ...is caring
	//-------------------------------------
	
	@IBAction func shareAlbum()
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
	
	
	@IBAction func sharePhoto()
	{
		let selectedIndex = photoBrowser?.currentIndex
		let image = collectionContent[Int(selectedIndex!)]

		let photo = photoBrowser?.imageForPhoto(photoBrowser?.photoAtIndex(UInt(selectedIndex!)))
		
		let reportImage = ReportImageActivity();
		let vc = UIActivityViewController(activityItems: [image, photo!], applicationActivities:[reportImage])
		vc.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePrint]
		self.presentViewController(vc, animated: true, completion: nil)
		
	}
	
	@IBAction func likePhoto()
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
		
			let selectedIndex = self.photoBrowser?.currentIndex
			let image = self.collectionContent[Int(selectedIndex!)]
			let liked = contains(image.likedBy, PFUser.currentUser()!.username!)
			if (liked) {
				let index = find(image.likedBy, PFUser.currentUser()!.username!)
				image.likedBy.removeAtIndex(index!)
				image.likes -= 1
			} else {
				image.likedBy.append(PFUser.currentUser()!.username!)
				image.likes += 1
			}
			
			var photo = PFObject(className: "Photo")
			photo.objectId = image.objectId
			photo["upvoteCount"] = image.likes
			photo["usersLiked"] = image.likedBy
			
			photo.saveInBackground()
			
			dispatch_async(dispatch_get_main_queue(), {
				
				self.likeLabel.text = NSString(format: "%i likes", image.likes) as String
				
				let liked = contains(image.likedBy, PFUser.currentUser()!.username!)
				if (liked) {
					self.likeButton?.image = UIImage(named: "heart-icon-filled")
				} else {
					self.likeButton?.image = UIImage(named: "heart-icon-empty")
				}
			})
			
		})
	}
	
	func flagPhoto(sender: AnyObject)
	{
		dispatch_async(dispatch_get_main_queue(), {
			var alertController = UIAlertController(title: "Flag inappropriate content", message: "What's wrong with this photo?", preferredStyle: .Alert)
			alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in }
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Flag", style: .Default, handler: { (UIAlertAction) -> Void in
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
					
					let selectedIndex = self.photoBrowser?.currentIndex
					let image = self.collectionContent[Int(selectedIndex!)]
					
					
					let textField = alertController.textFields?.first as! UITextField
					var photo = PFObject(className: "Photo")
					photo.objectId = image.objectId
					photo["flagged"] = true
					photo["reviewed"] = false
					photo["blocked"] = false
					photo["reporter"] = PFUser.currentUser()!.objectId
					photo["reportMessage"] = textField.text
					
					photo.saveInBackground()
					
					
					var imageIndex = find(self.collectionContent, image)
					self.collectionContent.removeAtIndex(imageIndex!)
					
					imageIndex = find(self.orginalContent, image)
					self.orginalContent.removeAtIndex(imageIndex!)
					
					dispatch_async(dispatch_get_main_queue(), {
						self.photoBrowser?.reloadData()
						self.collectionView?.reloadData()
					})
					
				})
				
			}))
			self.presentViewController(alertController, animated: true, completion: nil)
		})
		
	}

	
	
	
	
	//-------------------------------------
	// MARK: Data Source
	//-------------------------------------
	
	func updateData()
	{
		
		if (self.eventId == nil) {
			print("eventId < 0, NOP'ing out")
			return
		}
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			
			var imagesQuery = PFQuery(className: "Event")
			imagesQuery.limit = 1
			// imagesQuery.selectKeys(["name","photos"])
			imagesQuery.whereKey("objectId", equalTo: self.eventId!)
			let uploadedImages = imagesQuery.findObjects()
			
			if (uploadedImages?.count < 1) {
				print("No Photos/ No Updates")
				dispatch_async(dispatch_get_main_queue()) {
					self.spinner.stopAnimating()
					self.refreshControl.endRefreshing()
				}
			} else {
				let _object = uploadedImages!.first as! PFObject
				let _photos = _object["photos"] as! PFRelation
				
				if (_object["name"] != nil) {
					self.navigationItem.title = _object["name"] as? String
					self.eventTitle = _object["name"] as? String
				}
				
				let photosQuery = _photos.query()!
				photosQuery.limit = 300
				photosQuery.whereKey("flagged", notEqualTo: true)
				photosQuery.whereKey("blocked", notEqualTo: true)
				let photos = photosQuery.findObjects()
				
				if (photos?.count < 0) {
					print("No Photos/ No Updates")
					dispatch_async(dispatch_get_main_queue()) {
						self.spinner.stopAnimating()
						self.refreshControl.endRefreshing()
					}
				} else {
					
					self.collectionContent.removeAll(keepCapacity: true)
					for photo in photos! {
						
						let image = Image(text: "Check out this photo!")
						image.objectId = photo.objectId
						image.likes = photo["upvoteCount"] as! Int
						image.image = photo["image"] as! PFFile
						image.thumbnail = photo["thumbnail"] as! PFFile
						image.createdAt = photo.createdAt
						image.likedBy = photo["usersLiked"] as! [String]
						
						self.collectionContent.append(image)
					}
					self.orginalContent = self.collectionContent
					
					
					self.segementedControlValueChanged(self.segmentedControl)
					
					dispatch_async(dispatch_get_main_queue()) {
						self.collectionView?.reloadData()
						self.spinner.stopAnimating()
						self.refreshControl.endRefreshing()
					}
				}
				
				
			}
			
		})
		
	}
	
}