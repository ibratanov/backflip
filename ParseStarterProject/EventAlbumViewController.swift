//
//  EventAlbumViewController.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-07.
//  Copyright (c) 2015 Parse. All rights reserved.
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
	let CELL_REUSE_IDENTIFIER = "album-cell"
	var collectionContent : [Image] = []
	var photoBrowser : MWPhotoBrowser?
	var cameraButton : UIButton?
	
	@IBOutlet weak var segmentedControl : UISegmentedControl!
	let spinner : UIActivityIndicatorView = UIActivityIndicatorView()
	let refreshControl : UIRefreshControl = UIRefreshControl.new()
	
	
	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
		
		flow.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
		flow.itemSize = CGSizeMake((self.view.frame.size.width/3)-1, (self.view.frame.size.width/3)-1);
		flow.minimumInteritemSpacing = 1;
		flow.minimumLineSpacing = 1;
		
		
		cameraButton = UIButton.buttonWithType(.Custom) as? UIButton
		cameraButton?.setImage(UIImage(named: "goto-camera"), forState: .Normal)
		cameraButton?.backgroundColor = UIColor(red:0.063,  green:0.518,  blue:0.459, alpha:1)
		cameraButton?.frame = CGRectMake(0, (self.view.frame.size.height-(75+44)), self.view.frame.size.width, 75)
		cameraButton?.imageView?.sizeToFit()
		self.view?.addSubview(cameraButton!)
		self.view?.bringSubviewToFront(cameraButton!)
		
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		updateData()
		
		self.title = self.eventTitle
		
		refreshControl.tintColor = UIColor(red:0,  green:0.588,  blue:0.533, alpha:1)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: "updateData", forControlEvents: .ValueChanged)
		self.collectionView!.addSubview(refreshControl)
		
		self.collectionView?.contentInset = UIEdgeInsetsMake(0.0,0.0,72.0,0.0)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle
	{
		return .LightContent
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
	
	
	
	//-------------------------------------
	// MARK: UICollectionViewDelegate
	//-------------------------------------
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return Int(collectionContent.count)
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! AlbumViewCell
		
		cell.imageView.file = collectionContent[Int(indexPath.row)].thumbnail
		cell.imageView.loadInBackground()
		
		cell.layer.shouldRasterize = true
		cell.layer.rasterizationScale = UIScreen.mainScreen().scale
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		photoBrowser = MWPhotoBrowser(delegate: self)
		photoBrowser?.alwaysShowControls = true
		
		// Our own custom share button
		let shareBarButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sharePhoto")
		photoBrowser?.navigationItem.rightBarButtonItem = shareBarButton
		
		photoBrowser?.setCurrentPhotoIndex(UInt(indexPath.row))
		
		self.navigationController?.pushViewController(photoBrowser!, animated: true)
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
		let segementedControl = sender as! UISegmentedControl
		var content = self.collectionContent
		
		self.collectionContent.removeAll(keepCapacity: true)
		self.collectionView?.reloadData()
		
		if segementedControl.selectedSegmentIndex == 0 {
			content.sort{ $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending }
			self.collectionView?.reloadData()
		} else if segementedControl.selectedSegmentIndex == 1 {
			content.sort{ $0.likes > $1.likes }
			self.collectionView?.reloadData()
		} else if segementedControl.selectedSegmentIndex == 2 {
			println("Sorting by 'My Photos'..")
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
			imagesQuery.selectKeys(["photos"])
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
						
						self.collectionContent.append(image)
					}
					
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