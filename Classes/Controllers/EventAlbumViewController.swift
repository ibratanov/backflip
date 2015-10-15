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
import MapleBacon
import Foundation
import MagicalRecord


class EventAlbumViewController : UICollectionViewController, MWPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate
{
	
	//-------------------------------------
	// MARK: Global Variables
	//-------------------------------------
	
	var event : Event?
	
	let CELL_REUSE_IDENTIFIER = "album-cell"
	let ADD_CELL_REUSE_IDENTIFIER = "add-album-cell"
	
	var collectionContent : [Photo] = []
	
	var photoBrowser : MWPhotoBrowser?
	
	var likeButton : DOFavoriteButton?
	var likeLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 100, 21))
	
	
	@IBOutlet weak var segmentedControl : UISegmentedControl!
	let spinner : UIActivityIndicatorView = UIActivityIndicatorView()
	let refreshControl : UIRefreshControl = UIRefreshControl()
	
	
	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
	override func loadView()
	{
		super.loadView()
		
		self.navigationController?.tabBarController?.delegate = BFTabBarControllerDelegate.sharedDelegate
	}

	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		UIApplication.sharedApplication().statusBarHidden = false

		#if FEATURE_GOOGLE_ANALYTICS
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Event Album")
            //tracker.set("&uid", value: PFUser.currentUser()?.objectId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: PFUser.currentUser()?.objectId)
            
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
		#endif
    }
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.title = self.event?.name
		
		let titleLabel = UILabel(frame: CGRectZero)
		titleLabel.text = self.event?.name
		titleLabel.textColor = UIColor.whiteColor()
		titleLabel.userInteractionEnabled = true
		titleLabel.textAlignment = .Center
		let width = titleLabel.sizeThatFits(CGSizeMake(self.view.bounds.size.width, CGFloat.max)).width
		titleLabel.frame = CGRect(origin:CGPointZero, size:CGSizeMake(width, 44))
		self.navigationItem.titleView = titleLabel
		
		
		
		// Hide the "leave" button when pushed from event history
		let currentEventId = NSUserDefaults.standardUserDefaults().valueForKey("checkin_event_id") as? String
		if (currentEventId == self.event?.objectId) {
			self.navigationController?.setViewControllers([self], animated: false)
			
			let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
			self.navigationItem.titleView?.addGestureRecognizer(longPressRecognizer)
		} else {
			self.navigationItem.leftBarButtonItem = nil
		}
		
		updateData()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoUploaded", name: "camera-photo-uploaded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "flagPhoto:", name: "BFImageReportActivitySelected", object: nil)
		
		refreshControl.tintColor = UIColor(red:0,  green:0.588,  blue:0.533, alpha:1)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: "refreshData", forControlEvents: .ValueChanged)
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
		let alertController = UIAlertController(title: "Leave Event", message: "Are you sure you want to leave? This event will be moved to your event history.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Leave", style: .Destructive, handler: { (alertAction) -> Void in
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
			NSUserDefaults.standardUserDefaults().synchronize()
			
			
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
	
	
	func longPressed(sender: UILongPressGestureRecognizer)
	{
		if (self.event != nil && self.event?.owner! == PFUser.currentUser()!.objectId!) {
			
			let popover = EventEditingPopover()
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
	
	func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController)
	{
		popoverPresentationController.sourceView = self.navigationController!.navigationBar
		popoverPresentationController.sourceRect = CGRectMake(0, 0, self.view.frame.size.width, 40)
	}
	
	func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController)
	{
		let popover = popoverPresentationController.presentedViewController as! EventEditingPopover
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
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
	{
		return .None
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
		
		let photo = collectionContent[Int(index)]
		let _photo = MWPhoto(URL: NSURL(string: photo.image!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://")))
	
		if (photo.caption != nil && photo.caption?.characters.count > 1 && photo.caption != "Camera roll upload") {
			_photo.caption = photo.caption
		}
		
		
		return _photo
	}
	
	func photoBrowser(photoBrowser: MWPhotoBrowser!, didDisplayPhotoAtIndex index: UInt)
	{
		let photo = collectionContent[Int(index)]
		likeLabel.text = NSString(format: "%i likes", photo.upvoteCount!.integerValue) as String

		if (photo.usersLiked != nil) {
			let liked = photo.usersLiked!.contains(PFUser.currentUser()!.username!)
			if (liked) {
				likeButton!.select()
			} else {
				likeButton!.deselect()
			}
		} else {
			likeButton!.deselect()
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
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! AlbumViewCell
		if (indexPath.row == 0) {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(ADD_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! AlbumViewCell
		}
			
		if (indexPath.row == 0) {
			
			cell.imageView!.image = UIImage(named: "album-add-photo")
			cell.imageView!.image!.imageWithRenderingMode(.AlwaysTemplate)
			cell.imageView!.contentMode = .ScaleAspectFit
			cell.imageView!.tintColor = UIColor.grayColor()
			
		} else if (self.collectionContent.count >= indexPath.row) {
			
			let photo = collectionContent[Int(indexPath.row)-1]
			let imageUrl = NSURL(string: photo.image!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!

			if (cell.imageUrl != imageUrl) {
				cell.imageView?.image = nil
			}

			cell.imageUrl = imageUrl
			cell.imageView!.setImageWithURL(imageUrl, placeholder: nil, crossFadePlaceholder: true, cacheScaled: true, completion: nil)
		
		}
		
		cell.layer.shouldRasterize = true
		cell.layer.rasterizationScale = UIScreen.mainScreen().scale
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row == 0) {

			BFTabBarControllerDelegate.sharedDelegate.displayImagePickerSheet(self.event!)
			
		} else {
		
			photoBrowser = MWPhotoBrowser(delegate: self)
			photoBrowser?.alwaysShowControls = true
			photoBrowser?.displayActionButton = false
		
			// Our own custom share button
			let shareBarButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: "sharePhoto")
			shareBarButton.image = UIImage(named: "more-icon")
		
		
			// Toolbar items
			let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
		
			likeButton = DOFavoriteButton(frame: CGRectMake(0, 0, 50, 44), image: UIImage(named: "heart-icon-empty"))
			likeButton!.addTarget(self, action: Selector("likePhoto"), forControlEvents: .TouchUpInside)
			likeButton!.imageColorOff = UIColor.whiteColor()
			likeButton!.imageColorOn = UIColor(red:1,  green:0.412,  blue:0.384, alpha:1)
			likeButton!.lineColor = UIColor(red:1,  green:0.412,  blue:0.384, alpha:1)
			likeButton!.circleColor = UIColor(red:1,  green:0.412,  blue:0.384, alpha:1)
		
			likeLabel.font = UIFont(name: "Avenir-Medium", size: 16)
			likeLabel.textColor = UIColor.whiteColor()
			likeLabel.backgroundColor = UIColor.clearColor()
		
			let likeLabelButton = UIBarButtonItem(customView: likeLabel)
			let likeBarButton = UIBarButtonItem(customView: likeButton!)
			likeBarButton.width = 40
			
			photoBrowser?.toolbar?.items = [likeBarButton, likeLabelButton, flexSpace, shareBarButton]
			
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
	
	
	func tapped(sender: DOFavoriteButton) {
		if sender.selected {
			// deselect
			sender.deselect()
		} else {
			// select with animation
			sender.select()
		}
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
		
		self.collectionContent.removeAll(keepCapacity: true)
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
					let liked = photo.usersLiked!.contains(PFUser.currentUser()!.username!)
					if (liked) {
						content.append(photo)
					}
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
		
		PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Retriving invite code…")
		PKHUD.sharedHUD.show()
		
		let params = [ "referringUsername": "\(user)", "referringOut": "AVC", "eventObject": self.event!.objectId!, "eventId":"\(self.event!.objectId!)", "eventTitle": "\(self.event!.name!)"]
		Branch.getInstance().getShortURLWithParams(params, andChannel: "SMS", andFeature: "Referral", andCallback: { (url: String!, error: NSError!) -> Void in
			if (error != nil) {
				
				PKHUD.sharedHUD.hideAnimated()
				
				NSLog("Branch short URL generation failed, %@", error);
				
				let alertController = UIAlertController(title: "Invite Friends", message: "Whoops, it appears we're having trouble generating a link to share with your friends. Please try again later", preferredStyle: .Alert)
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

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
		
			
			
			MagicalRecord.saveWithBlock({ (context) -> Void in
				
				let selectedIndex = self.photoBrowser?.currentIndex
				let _photo = self.collectionContent[Int(selectedIndex!)]
				let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: _photo.objectId) as! Photo
				
				
				if (photo.usersLiked == nil) {
					photo.usersLiked = ""
				}
				
				let liked = photo.usersLiked!.contains(PFUser.currentUser()!.username!)
				if (liked) {
					var liked = photo.usersLiked!.componentsSeparatedByString(",")
					let index = liked.indexOf(PFUser.currentUser()!.username!)  // find(liked, PFUser.currentUser()!.username!)
					liked.removeAtIndex(index!)
					photo.usersLiked = liked.joinWithSeparator(",")
					
					photo.upvoteCount = photo.upvoteCount!.integerValue - 1
				} else {
					var liked = photo.usersLiked!.componentsSeparatedByString(",")
					liked.append(PFUser.currentUser()!.username!)
					photo.usersLiked = liked.joinWithSeparator(",")

					photo.upvoteCount = photo.upvoteCount!.integerValue + 1
				}
				
			}, completion: { (completed, error) -> Void in
				
				let selectedIndex = self.photoBrowser?.currentIndex
				let _photo = self.collectionContent[Int(selectedIndex!)]
				let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: _photo.objectId) as! Photo
				
				let photoObject = PFObject(className: "Photo")
				photoObject.objectId = photo.objectId
				photoObject["upvoteCount"] = photo.upvoteCount
				if (photo.usersLiked != nil) {
					photoObject["usersLiked"] = photo.usersLiked!.componentsSeparatedByString(",")
				}
				
				photoObject.saveInBackground()
				
				dispatch_async(dispatch_get_main_queue(), {
					
					self.likeLabel.text = NSString(format: "%i likes", photo.upvoteCount!.integerValue) as String
					
					let selectedIndex = self.photoBrowser?.currentIndex
					let _photo = self.collectionContent[Int(selectedIndex!)]
					let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: _photo.objectId) as! Photo
					if (photo.usersLiked != nil) {
						let liked = photo.usersLiked!.contains(PFUser.currentUser()!.username!)
						if (liked) {
							self.likeButton!.select()
						} else {
							self.likeButton!.deselect()
						}
					}
					
				})

				
			})
			
		})
	}
	
	func flagPhoto(sender: AnyObject)
	{
		dispatch_async(dispatch_get_main_queue(), {
			let alertController = UIAlertController(title: "Flag inappropriate content", message: "What's wrong with this photo?", preferredStyle: .Alert)
			alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in }
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Flag", style: .Default, handler: { (UIAlertAction) -> Void in
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
					
					let selectedIndex = self.photoBrowser?.currentIndex
					let image = self.collectionContent[Int(selectedIndex!)]
					
					
					let textField = alertController.textFields!.first! 
					let photo = PFObject(className: "Photo")
					photo.objectId = image.objectId
					photo["flagged"] = true
					photo["reviewed"] = false
					photo["blocked"] = false
					photo["reporter"] = PFUser.currentUser()!.objectId
					photo["reportMessage"] = textField.text
					
					photo.saveInBackgroundWithBlock({ (success, error) -> Void in
						
						BFDataProcessor.sharedProcessor.processPhotos([photo], completion: { () -> Void in
							print("Photo saved")
						})
						
					})
					
					
					let imageIndex = self.collectionContent.indexOf(image)
					self.collectionContent.removeAtIndex(imageIndex!)
					
					// imageIndex = find(self.orginalContent, image)
					// self.orginalContent.removeAtIndex(imageIndex!)
					
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
	// MARK: Memory
	//-------------------------------------
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
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
		
		var photos : [Photo] = []
		let _photos : [Photo] = event?.photos?.allObjects as! [Photo]
		for photo : Photo in _photos {
			if (photo.flagged != nil && Bool(photo.flagged!) == true) {
				continue
			}
			
			photos.append(photo)
		}
		
		
		if (photos.count < 1) {
			print("No Photos/ No Updates")
			dispatch_async(dispatch_get_main_queue()) {
				self.spinner.stopAnimating()
				self.refreshControl.endRefreshing()
			}
		} else {
		
			self.collectionContent = photos
			
			if (self.segmentedControl != nil) {
				self.segementedControlValueChanged(self.segmentedControl)
			} else {
				let _segmentedControl = UISegmentedControl()
				_segmentedControl.selectedSegmentIndex = 0;
				self.segementedControlValueChanged(_segmentedControl)
			}
			
//            for photo : Photo in photos {
//                println("curl -O \""+photo.image!.url!+"\" &&")
//            }
            
			dispatch_async(dispatch_get_main_queue()) {
				self.collectionView?.reloadData()
				self.spinner.stopAnimating()
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




class EventEditingPopover : PopoverView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
	var event : Event?
	var tableView : UITableView?
	
	var eventName : UITextField?
	var eventSwitch : UISwitch?
	
	
	override init()
	{
		super.init()
		
		self.tableView = UITableView(frame: self.view.bounds, style: .Plain)
		self.tableView?.dataSource = self
		self.tableView?.delegate = self
		self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView?.estimatedRowHeight = 88
		self.view.addSubview(self.tableView!)
	}

	required init?(coder aDecoder: NSCoder)
	{
	    fatalError("init(coder:) has not been implemented")
	}
	
	
	//-------------------------------------
	// MARK: View Layout
	//-------------------------------------
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.tableView?.frame = self.view.bounds
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		self.tableView?.frame = self.view.bounds
	}
	
	
	
	//-------------------------------------
	// MARK: Table View Delegate
	//-------------------------------------
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 2
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return 66
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = self.tableView?.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath)
		cell?.selectionStyle = .None
		
		if (indexPath.row == 0) {
			
			cell?.textLabel!.text = "Event Name"
			
			eventName = UITextField(frame: CGRectMake(self.view.bounds.size.width - 230, 0, 220, 66))
			eventName?.adjustsFontSizeToFitWidth = true
			eventName?.textColor = UIColor.blackColor()
			eventName?.placeholder = "Event name"
			eventName?.text = event?.name
			eventName?.textColor = UIColor.grayColor()
			eventName?.keyboardType = .Default
			eventName?.returnKeyType = .Done
			eventName?.backgroundColor = UIColor.clearColor()
			eventName?.autocorrectionType = .No
			eventName?.autocapitalizationType = .None
			eventName?.textAlignment = .Right
			eventName?.clearButtonMode = .Never
			eventName?.delegate = self
			cell?.contentView.addSubview(eventName!)

		} else if (indexPath.row == 1) {
			
			cell?.textLabel!.text = "Private Event"
			
			eventSwitch = UISwitch(frame: CGRectMake(self.view.bounds.size.width - 55, 16, 94, 44))
			eventSwitch!.on = !(event!.live!.boolValue)
			
			cell?.contentView.addSubview(eventSwitch!)
		}


		return cell!
	}
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		if (indexPath.row == 0) {
			eventName?.becomeFirstResponder()
		} else if (indexPath.row == 1) {
			eventSwitch?.setOn(!(eventSwitch!.on), animated: true)
		}
	}

	
	//-------------------------------------
	// MARK: TextField Delegate
	//-------------------------------------
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
	{
		
//		if (range.length + range.location > textField.text!.characters.count) {
//			return false;
//		}

		let newLength = textField.text!.characters.count + string.characters.count - range.length;
		
		return newLength < 26
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		if (textField.text!.characters.count < 1) {
			return false
		}
		
		eventName?.resignFirstResponder()
		eventName?.endEditing(true)
		
		return true
	}

}