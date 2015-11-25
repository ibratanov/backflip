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
import Kingfisher
import Foundation
import MagicalRecord

import SKPhotoBrowser


public class EventAlbumViewController : BFCollectionViewController, UIPopoverPresentationControllerDelegate, SKPhotoBrowserDelegate
{
	
	//-------------------------------------
	// MARK: Global Variables
	//-------------------------------------
	
	public var event: Event?
	
	public var currentEvent: Bool = false
	
	
	/**
	 * Collection View Cell reuse identifier
	*/
	internal let ADD_CELL_REUSE_IDENTIFIER = "add-album-cell"

	
	/**
	 * Collection View Content
	*/
	private var content: [Photo] = []
	
	
	/**
	 * Photo browser
	*/
	private var photoBrowser: BFPhotoBrowser?
	
	/**
	 * Segmented Control
	*/
	@IBOutlet weak var segmentedControl : UISegmentedControl!
	
	/**
	 * Refresh Control
	*/
	let refreshControl: UIRefreshControl = UIRefreshControl()

	
	
	//-------------------------------------
	// MARK: - View Delegate
	//-------------------------------------
	
	public override func loadView()
	{
		super.loadView()
		
		self.navigationController?.tabBarController?.delegate = BFTabBarControllerDelegate.sharedDelegate
	}

	public override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		UIApplication.sharedApplication().statusBarHidden = false
		
		if (self.currentEvent == true) {
			if (self.event?.owner == PFUser.currentUser()?.objectId) {
				let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
				self.navigationItem.titleView?.addGestureRecognizer(longPressRecognizer)
			}
		} else {
			self.navigationItem.leftBarButtonItem = nil
		}
    }
	
	public override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
	}
	
	public override func viewDidLoad()
	{
		super.viewDidLoad()
		
		if (self.currentEvent == false) { // So this doesn't effect the UITabBarItem's title
			self.title = self.event?.name
			self.navigationItem.title = self.event?.name
		}
		
		let titleLabel = UILabel(frame: CGRectZero)
		titleLabel.text = self.event?.name
		titleLabel.textColor = UIColor.whiteColor()
		titleLabel.userInteractionEnabled = true
		titleLabel.textAlignment = .Center
		let width = titleLabel.sizeThatFits(CGSizeMake(self.view.bounds.size.width, CGFloat.max)).width
		titleLabel.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 44))
		
		if (self.currentEvent == true) {
			self.navigationController?.navigationBar.topItem?.titleView = titleLabel
		} else {
			self.navigationItem.titleView = titleLabel
		}
		
		self.updateData()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoUploaded", name: "camera-photo-uploaded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "flagPhoto:", name: "BFImageReportActivitySelected", object: nil)
		
		self.refreshControl.tintColor = UIColor(red:0,  green:0.588,  blue:0.533, alpha:1)
		self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		self.refreshControl.addTarget(self, action: "refreshData", forControlEvents: .ValueChanged)
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
	
	public override func preferredStatusBarStyle() -> UIStatusBarStyle
	{
		return .LightContent
	}
	
	
	
	//-------------------------------------
	// MARK: Actions
	//-------------------------------------
	
	@IBAction func leaveEvent()
	{
		let alertController = UIAlertController(title: "Leave Event", message: "Are you sure you want to leave? This event will be moved to your Event History.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Leave", style: .Destructive, handler: { (alertAction) -> Void in
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
			NSUserDefaults.standardUserDefaults().synchronize()
			
			
			let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
			let currentViewController = storyboard.instantiateViewControllerWithIdentifier("current-viewcontroller")
			self.navigationController?.setViewControllers([currentViewController], animated: false)

		}))
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	
	public func photoUploaded()
	{
		self.updateData()
	}
	
	
	public func longPressed(sender: UILongPressGestureRecognizer)
	{
		if (self.event != nil && self.event?.owner! == PFUser.currentUser()!.objectId!) {
			
			let popover = EventEditingView()
			popover.event = self.event
			popover.modalPresentationStyle = .Popover
			popover.preferredContentSize = CGSizeMake(self.view.frame.size.width - 20, 132)
			popover.popoverPresentationController?.delegate = self
			popover.popoverPresentationController?.sourceView = self.navigationController!.navigationBar
			popover.popoverPresentationController?.sourceRect = CGRectMake(0, 0, self.view.frame.size.width, 40)
			self.presentViewController(popover, animated: true, completion: nil)

			
		}
		
	}
	
	
	//-------------------------------------
	// MARK: Popover Presentation Delegate
	//-------------------------------------
	
	public func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController)
	{
		popoverPresentationController.sourceView = self.navigationController!.navigationBar
		popoverPresentationController.sourceRect = CGRectMake(0, 0, self.view.frame.size.width, 40)
	}
	
	public func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController)
	{
		let popover = popoverPresentationController.presentedViewController as! EventEditingView
		if ( popover.eventName!.text! != event!.name!  || popover.eventSwitch!.on != !(event!.live!.boolValue) ) {

			PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Saving..")
			PKHUD.sharedHUD.show()
			
			let eventObject = PFObject(className: "Event")
			eventObject.objectId = event!.objectId!
			eventObject.setObject(popover.eventName!.text!, forKey: "eventName")
			eventObject.setObject(!(popover.eventSwitch!.on), forKey: "isLive")
			eventObject.saveInBackgroundWithBlock({ (success, error) -> Void in
				
				BFDataProcessor.sharedProcessor.processEvents([eventObject], completion: { () -> Void in
										
					let width = self.navigationItem.titleView?.sizeThatFits(CGSizeMake(self.view.bounds.size.width, CGFloat.max)).width
					self.navigationItem.titleView?.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width!, 44))
					
					// self.title = eventObject["eventName"] as? String
					(self.navigationItem.titleView as! UILabel).text = eventObject["eventName"] as? String
					PKHUD.sharedHUD.hide(animated: true)
					
				})
				
			})
			
			
		}
	
	}
	
	public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
	{
		return .None
	}
	
	
	//-------------------------------------
	// MARK: MWPhotoBrowserDelegate
	//-------------------------------------
	
	public func didShowPhotoAtIndex(index: Int)
	{
		if (index > (content.count - 1) || index < 0) {
			return
		}
		
		let photo = content[index]
		
		photoBrowser?.likeLabel.text = "\(photo.upvoteCount!) like"+((photo.upvoteCount?.intValue > 1 || photo.upvoteCount?.intValue == 0) ? "s" : "")
		if (photo.usersLiked != nil) {
			if (photo.likedBy(PFUser.currentUser())) {
				self.photoBrowser?.likeButton?.tintColor = UIColor(red:1,  green:0.216,  blue:0.173, alpha:1)
				self.photoBrowser?.likeButton?.image = UIImage(named: "PUFavoriteOn")
			} else {
				self.photoBrowser?.likeButton?.tintColor = UIColor.whiteColor()
				self.photoBrowser?.likeButton?.image = UIImage(named: "PUFavoriteOff")
			}
		}
		
		if (photo.uploader == PFUser.currentUser()?.objectId) {
			self.photoBrowser?.trashButton?.image = UIImage(named: "UIButtonBarTrash")
			self.photoBrowser?.trashButton?.action = "deletePhoto"
		} else {
			self.photoBrowser?.trashButton?.image = UIImage(named: "UIButtonBarFlag")
			self.photoBrowser?.trashButton?.action = "flagPhoto"
		}
		
	}
	
	
	//-------------------------------------
	// MARK: UICollectionViewDelegate
	//-------------------------------------
	
	public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return (1 + Int(self.content.count))
	}
	
	public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		var cell : EventAlbumCell?
		if (indexPath.row == 0) {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(ADD_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as? EventAlbumCell
			cell?.backgroundColor = UIColor.clearColor()
		} else {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(EventAlbumCell.reuseIdentifier, forIndexPath: indexPath) as? EventAlbumCell
		}
			
		if (indexPath.row == 0) {
			cell!.imageView!.image = UIImage(named: "album-cell-add-photo")
		} else if (self.content.count >= indexPath.row) {
		
		}
		
		return cell!
	}
	
	public override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row > 0) {
			guard let cell = cell as? EventAlbumCell else { fatalError("Expected to display a `EventAlbumCell`.") }
			
			let photo = content[Int(indexPath.row)-1]
			
			let imageUrl = NSURL(string: photo.thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
			cell.imageView.kf_setImageWithURL(imageUrl, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))])
		}
	}
	
	public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row == 0) {

			BFTabBarControllerDelegate.sharedDelegate.displayImagePickerSheet(self.event!)
			
		} else {
		
			// Photos
			var images = [SKPhoto]()
			for photo in content {
				let image = SKPhoto.photoWithImageURL(photo.image!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))
				image.shouldCachePhotoURLImage = true
				
				if (photo.caption != nil && photo.caption?.characters.count > 1 && photo.caption != "Camera roll upload") {
					image.caption = photo.caption
				}
				
				images.append(image)
			}
			
			
			UIToolbar.appearance().tintColor = UIColor.whiteColor()
			UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
			
			
			let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EventAlbumCell
			let originImage = cell.imageView?.image // some image for baseImage
			photoBrowser = BFPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell)
			photoBrowser!.initializePageIndex(indexPath.row - 1)
			photoBrowser?.delegate = self
			
			photoBrowser!.displayToolbar = true
			photoBrowser!.displayCounterLabel = false
			photoBrowser!.displayBackAndForwardButton = false
			
			photoBrowser?.shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sharePhoto")
			
			photoBrowser?.trashButton = UIBarButtonItem(image: UIImage(named: "UIButtonBarTrash"), style: .Plain, target: self, action: "flagPhoto")
			
			photoBrowser?.likeButton = UIBarButtonItem(image: UIImage(named: "PUFavoriteOff"), style: .Plain, target: self, action: "likePhoto")
			
			self.presentViewController(photoBrowser!, animated: true, completion: {})
		}
	}
	
	public override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
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
		
		var photos : [Photo] = []
		let _photos : [Photo] = event?.photos?.allObjects as! [Photo]
		for photo : Photo in _photos {
			if (photo.flagged != nil && Bool(photo.flagged!) == true) {
				continue
			}
			
			photos.append(photo)
		}
		
		if (photos.count < 1) {
			return
		}
		
		var content = photos
		let segementedControl = sender as! UISegmentedControl
		
		self.content.removeAll(keepCapacity: true)
		self.collectionView?.reloadData()
		
		if segementedControl.selectedSegmentIndex <= 0 {
			content.sortInPlace{ if ($0.createdAt != nil && $1.createdAt != nil) { return ($0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending) } else { return false } }
		} else if segementedControl.selectedSegmentIndex == 1 {
			content.sortInPlace{ $0.upvoteCount!.integerValue > $1.upvoteCount!.integerValue }
		} else if segementedControl.selectedSegmentIndex == 2 {
			content.removeAll(keepCapacity: true)
			for (var i = 0; i < photos.count; i++) {
				let photo = photos[i]
				if (photo.usersLiked != nil) {
					if (photo.likedBy(PFUser.currentUser())) {
						content.append(photo)
					}
				}
			}
		}
		
		self.content = content

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
		
		PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Retriving invite code…")
		PKHUD.sharedHUD.show()
		
		let params = [ "referringUsername": "\(user)", "referringOut": "AVC", "eventObject": self.event!.objectId!, "eventId":"\(self.event!.objectId!)", "eventTitle": "\(self.event!.name!)"]
		Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
			if (error != nil) {
				
				PKHUD.sharedHUD.hideAnimated()
				
				NSLog("Branch short URL generation failed, %@", error);
				
				let alertController = UIAlertController(title: "Invite Friends", message: "Whoops, it appears we're having trouble generating a link to share with your friends. Please try again.", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
				self.presentViewController(alertController, animated: true, completion: nil)
				
			} else {
				
				PKHUD.sharedHUD.hideAnimated()
				
				// Delay .2 seconds for visual effect
				let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
				dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.event!.inviteUrl = url

					// Now we share.
					let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [self.event!, NSURL(string: url)! ], applicationActivities: nil)
					activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop]
					self.presentViewController(activityViewController, animated: true, completion: nil)
				})
				
			}
			
		})
		
	}
	
	
	@IBAction func sharePhoto()
	{
		let selectedIndex = photoBrowser?.currentPageIndex
		let image = content[Int(selectedIndex!)]
		
		let photo = photoBrowser!.photos[selectedIndex!].underlyingImage
		
		let activityViewController = UIActivityViewController(activityItems: [image, photo], applicationActivities:nil)
		activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePrint]
		
		photoBrowser?.presentViewController(activityViewController, animated: true, completion: nil)
	}
	
	
	@IBAction func likePhoto()
	{

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
		
			MagicalRecord.saveWithBlock({ (context) -> Void in
				
				let selectedIndex = self.photoBrowser?.currentPageIndex
				let _photo = self.content[Int(selectedIndex!)]
				let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: _photo.objectId) as! Photo
				
				
				if (photo.usersLiked == nil) {
					photo.usersLiked = ""
				}

                print("Photo (un)like attempted:")
                print(photo.objectId!)
				
				if (photo.likedBy(PFUser.currentUser())) {
					let currentUser = PFUser.currentUser()
					var liked = photo.usersLiked!.componentsSeparatedByString(",")
					var index = liked.indexOf(PFUser.currentUser()!.objectId!)
					if (index == nil && currentUser!["phone"] != nil) {
						index = liked.indexOf((currentUser!["phone"] as! String))
					} else if (index == nil && currentUser!["facebook_id"] != nil) {
						index = liked.indexOf((currentUser!["facebook_id"] as! NSNumber).stringValue)
					}
					
					liked.removeAtIndex(index!)
					photo.usersLiked = liked.joinWithSeparator(",")
					
					photo.upvoteCount = photo.upvoteCount!.integerValue - 1
				} else {
					var liked = photo.usersLiked!.componentsSeparatedByString(",")
					liked.append(PFUser.currentUser()!.objectId!)
					photo.usersLiked = liked.joinWithSeparator(",")

					photo.upvoteCount = photo.upvoteCount!.integerValue + 1
				}
				
			}, completion: { (completed, error) -> Void in
				
				let selectedIndex = self.photoBrowser?.currentPageIndex
				let _photo = self.content[Int(selectedIndex!)]
				let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: _photo.objectId) as! Photo
				
				let photoObject = PFObject(className: "Photo")
				photoObject.objectId = photo.objectId
				photoObject["upvoteCount"] = photo.upvoteCount
				if (photo.usersLiked != nil) {
					photoObject["usersLiked"] = photo.usersLiked!.componentsSeparatedByString(",")
				}
				
				photoObject.saveInBackground()
				
				dispatch_async(dispatch_get_main_queue(), {
					
					self.photoBrowser?.likeLabel.text = NSString(format: "%i likes", photo.upvoteCount!.integerValue) as String
					
					let selectedIndex = self.photoBrowser?.currentPageIndex
					let _photo = self.content[Int(selectedIndex!)]
					let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: _photo.objectId) as! Photo
					if (photo.usersLiked != nil) {
						if (photo.likedBy(PFUser.currentUser())) {
							self.photoBrowser?.likeButton?.tintColor = UIColor(red:1,  green:0.216,  blue:0.173, alpha:1)
							self.photoBrowser?.likeButton?.image = UIImage(named: "PUFavoriteOn")
						} else {
							self.photoBrowser?.likeButton?.tintColor = UIColor.whiteColor()
							self.photoBrowser?.likeButton?.image = UIImage(named: "PUFavoriteOff")
						}
					}
					
				})

				
			})
			
		})
	}
	
	func flagPhoto()
	{
		dispatch_async(dispatch_get_main_queue(), {
			let alertController = UIAlertController(title: "Flag inappropriate content", message: "What's wrong with this photo?", preferredStyle: .Alert)
			alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in }
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Flag", style: .Default, handler: { (UIAlertAction) -> Void in
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
					
					let selectedIndex = self.photoBrowser?.currentPageIndex
					let image = self.content[Int(selectedIndex!)]
					
					let textField = alertController.textFields!.first! 
					let photo = PFObject(className: "Photo")
					photo.objectId = image.objectId
					photo["flagged"] = true
					photo["enabled"] = false
					photo["reviewed"] = false
					photo["blocked"] = false
					photo["reporter"] = PFUser.currentUser()!.objectId
					photo["reportMessage"] = textField.text
					
					photo.saveInBackgroundWithBlock({ (success, error) -> Void in
						
						BFDataProcessor.sharedProcessor.processPhotos([photo], completion: { () -> Void in
							print("Photo saved")
						})
						
					})
					
					
					let imageIndex = self.content.indexOf(image)
					self.content.removeAtIndex(imageIndex!)
					
					
					dispatch_async(dispatch_get_main_queue(), {
						self.photoBrowser?.dismissPhotoBrowser()
						self.collectionView?.reloadData()
					})
					
				})
				
			}))
			
			self.photoBrowser?.presentViewController(alertController, animated: true, completion: nil)
		})
		
	}

	
	func deletePhoto()
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			
			let selectedIndex = self.photoBrowser?.currentPageIndex
			let image = self.content[Int(selectedIndex!)]
			
			let photo = PFObject(className: "Photo")
			photo.objectId = image.objectId
			photo["flagged"] = true
			photo["reviewed"] = false
			photo["enabled"] = false
			photo["blocked"] = false
			photo["reporter"] = PFUser.currentUser()!.objectId
			photo["reportMessage"] = "Removed at request of owner"
			
			photo.saveInBackgroundWithBlock({ (success, error) -> Void in
				
				BFDataProcessor.sharedProcessor.processPhotos([photo], completion: { () -> Void in
					print("Photo saved")
				})
				
			})
			
			let imageIndex = self.content.indexOf(image)
			self.content.removeAtIndex(imageIndex!)
			
			dispatch_async(dispatch_get_main_queue(), {
				self.photoBrowser?.dismissPhotoBrowser()
				self.collectionView?.reloadData()
			})
			
		})
		
	}
	
	
	
	//-------------------------------------
	// MARK: Memory
	//-------------------------------------
	
	public override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	
	
	
	//-------------------------------------
	// MARK: Data Source
	//-------------------------------------
	
	func updateData()
	{
		if (self.event == nil) {
			print("No event passed to EventAlbumViewController :(");
			return
		}
		
		let photos = event!.cleanPhotos
		if (photos.count < 1) {
			print("No Photos/ No Updates")
			dispatch_async(dispatch_get_main_queue()) {
				self.refreshControl.endRefreshing()
			}
		} else {
		
			self.content = photos
			
			if (self.segmentedControl != nil) {
				self.segementedControlValueChanged(self.segmentedControl)
			} else {
				let _segmentedControl = UISegmentedControl()
				_segmentedControl.selectedSegmentIndex = 0;
				self.segementedControlValueChanged(_segmentedControl)
			}
            
			dispatch_async(dispatch_get_main_queue()) {
				self.collectionView?.reloadData()
				self.refreshControl.endRefreshing()
			}
		}
		
	}
	
	
	func refreshData()
	{
		BFDataFetcher.sharedFetcher.fetchDataInBackground { (completed) -> Void in
			self.updateData();

			let event = Event.MR_findFirstByAttribute("objectId", withValue: self.event!.objectId!)
			(self.navigationItem.titleView as? UILabel)?.text = event.name!
			(self.navigationItem.titleView as? UILabel)?.sizeToFit()
		}
	}
	
}
