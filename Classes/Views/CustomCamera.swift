//
//  CustomCamera.swift
//  Backflip
//
//  Created by MWars on 2015-08-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MobileCoreServices
import AssetsLibrary
import Foundation
import Photos
import MessageUI
import AVFoundation
import DigitsKit

class CustomCamera : UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,BFCImagePickerControllerDelegate, FastttCameraDelegate {
	
	//------------------FastttCamera----------------
	//var fastCamera = FastttFilterCamera()
	weak var fastCamera = FastttFilterCamera()
	weak var currentFilter = CustomFilter()
	
	
	enum FastttFilterType{
		case FastttCameraFilterNone
		case FastttCameraFilterRetro
		case FastttCameraFilterHighContrast
		case FastttCameraFilterBW
		case FastttCameraFilterSepia
		
		init() {
			self = .FastttCameraFilterNone
		}
	}
	
	lazy var context: CIContext = {
		return CIContext(options: nil)
		}()
	//------------------Camera Att.-----------------
	
	@IBOutlet weak var bottomBar: UIView!
	@IBOutlet weak var topBar: UIView!
	@IBOutlet weak var previewScreenView: UIView!
	@IBOutlet weak var thumbnailButton: UIButton!
	@IBOutlet weak var flashButton: UIButton!
	@IBOutlet var eventNameLabel : UILabel?
	
	
	var flashOff = UIImage(named:"flash-icon-off") as UIImage!
	var flashOn = UIImage(named:"flash-icon-on") as UIImage!
	var flashAuto = UIImage(named:"flash-icon-auto") as UIImage!
	
	var loopAllImagesBool = false
	let frame: CGRect = UIScreen.mainScreen().bounds
	
	var overlayView: UIView?
	var zoomImage = (camera: true, display: true)
	var newMedia: Bool = true
	
	var filterCount = 0
	// Hi, this the an "event" model object, you can find it's prop's in Event.swift Under Project > Models
	var event : Event?
	
	// Checker for sort button. Sort in chronological order by default.
	var sortedByLikes = true
	var myPhotoSelected = false
	var fullScreen = false
	var posted = false
	
	// Keeps track of photo source and only downloads newly taken images
	var downloadToCameraRoll = true
	
	//var fastFilter = FastttFilter()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.sharedApplication().statusBarHidden = true
		
		self.eventNameLabel?.text = self.event!.name!
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: ("handleSwipes:"))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: ("handleSwipes:"))
		
		leftSwipe.direction = .Left
		rightSwipe.direction = .Right
		
		view.addGestureRecognizer(leftSwipe)
		view.addGestureRecognizer(rightSwipe)
		//self.currentFilter.filterType = FastttFilterType.CameraFilterRetro
		//self.fastCamera = FastttFilterCamera(filterImage: self.currentFilter.filterImage)
		//self.fastCamera = FastttFilterCamera(filterImage: UIImage(named: "SepiaFilter"))
		
		// _currentFilter = [ExampleFilter filterWithType:FastttCameraFilterRetro];
		// _fastCamera = [FastttFilterCamera cameraWithFilterImage:self.currentFilter.filterImage];
		
		//self.currentFilter.filterWithType(CustomFilter.FastttFilterType.FastttCameraFilterRetro)
		//self.fastCamera = FastttFilterCamera(filterImage: self.currentFilter.filterImage)
		
		//self.currentFilter = self.currentFilter.nextFilter()
		//self.fastCamera.filterImage = self.currentFilter.filterImage
		//var filterImageSet = UIImage(named: "SepiaFilter")
		
		
		self.fastCamera!.delegate = self
		
		self.fastCamera!.supportedInterfaceOrientations()
		self.fastCamera!.willMoveToParentViewController(self)
		self.fastCamera!.beginAppearanceTransition(true, animated: false)
		self.addChildViewController(self.fastCamera!)
		self.view.insertSubview(self.fastCamera!.view, belowSubview: bottomBar)
		self.view.insertSubview(topBar, aboveSubview: bottomBar)
		self.fastCamera!.didMoveToParentViewController(self)
		self.fastCamera!.endAppearanceTransition()
		self.fastCamera!.view.frame = self.view.frame
		
		
		if (FastttFilterCamera.isCameraDeviceAvailable(FastttCameraDevice.Front)) {
			//self.fastCamera.cameraDevice = FastttCameraDevice.Front
		}
		
		if NetworkAvailable.networkConnection() == true {
			let query = PFUser.query()
			query?.selectKeys(["blocked"])
			query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
				if error == nil {
					if (object!.valueForKey("blocked") as! Bool) {
						PFUser.logOut()
						Digits.sharedInstance().logOut()
						self.performSegueWithIdentifier("logOutBlocked", sender: self)
					} else {
						self.fullScreen = false
						self.posted = true
						
						self.testCalled()
						
						self.setLastPhoto()
						self.updateThumbnail()
						
					}
				} else {
					
					print(error)
				}
			})
		} else {
			displayNoInternetAlert() }
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name: "_UIApplicationVolumeUpButtonDownNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name: "_UIApplicationVolumeDownButtonDownNotification", object: nil)
		
		
	}
	
	//--------------- Camera ---------------
	//initialize camera
	
	func saveImageAlert()
	{
		let alert:UIAlertView = UIAlertView()
		alert.title = "Saved!"
		alert.message = "Saved to Camera Roll"
		alert.delegate = self
		alert.addButtonWithTitle("Ok")
		alert.show()
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return false
	}
	
	func cropToSquare(image originalImage: UIImage) -> UIImage {
		// Get image and measurements
		let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
		let contextSize: CGSize = contextImage.size
		let posX: CGFloat
		let posY: CGFloat
		let width: CGFloat
		let height: CGFloat
		
		//Calibrate image for optimal crop
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
		let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage!, rect)!
		
		//Define original orientation
		//let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
		
		let image: UIImage = UIImage(CGImage: imageRef)
		
		return image
	}
	
	
	
	func testCalled()
	{
		
		let sourceType = UIImagePickerControllerSourceType.Camera
		if (!UIImagePickerController.isSourceTypeAvailable(sourceType))
		{
			let alert:UIAlertView = UIAlertView()
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
			let alert:UIAlertView = UIAlertView()
			alert.title = "Cannot access front-facing camera!"
			alert.message = " "
			alert.delegate = self
			alert.addButtonWithTitle("Ok")
			alert.show()
		}
		if (!UIImagePickerController.isCameraDeviceAvailable(rearCamera))
		{
			let alert:UIAlertView = UIAlertView()
			alert.title = "Cannot access rear-facing camera!"
			alert.message = " "
			alert.delegate = self
			alert.addButtonWithTitle("Ok")
			alert.show()
		}
		
		let status : AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
		if (status == AVAuthorizationStatus.Authorized) {
			print("authorized")
		} else if(status == AVAuthorizationStatus.Denied){
			let alert:UIAlertView = UIAlertView()
			alert.title = "Camera Disabled"
			alert.message = "Please enable camera access in the iOS settings for Backflip or upload from your camera roll."
			alert.delegate = self
			alert.addButtonWithTitle("Ok")
			alert.show()
		} else if(status == AVAuthorizationStatus.Restricted){
			let alert:UIAlertView = UIAlertView()
			alert.title = "Camera Disabled"
			alert.message = "Please enable camera access in the iOS settings for Backflip or upload from your camera roll."
			alert.delegate = self
			alert.addButtonWithTitle("Ok")
			alert.show()
		}
	}
	
	@IBAction func reverseCamera(sender: UIButton) {
		var cameraDevice: FastttCameraDevice
		switch (self.fastCamera!.cameraDevice) {
		case FastttCameraDevice.Front:
			cameraDevice = FastttCameraDevice.Rear
			break
			
		case FastttCameraDevice.Rear:
			cameraDevice = FastttCameraDevice.Front
			self.flashButton.hidden = true
			break
			
		default:
			cameraDevice = FastttCameraDevice.Front
			self.flashButton.hidden = true
		}
		
		if (FastttFilterCamera.isCameraDeviceAvailable(cameraDevice)) {
			self.fastCamera!.cameraDevice = cameraDevice
		}
		
		
	}
	
	@IBAction func showCameraRoll(sender: UIButton) {
		
		let pickerController = BFCImagePickerController()
		pickerController.pickerDelegate = self
		self.presentViewController(pickerController, animated: true) {}
	}
	
	//********call back functions for ^^^^**********
	func imagePickerControllerDidSelectedAssets(assets: [BFCAsset]!) {
		//Send assets to parse
		for (index, asset) in assets.enumerate() {
			let imageView = UIImageView(image: asset.fullScreenImage)
			imageView.contentMode = UIViewContentMode.ScaleAspectFit
			uploadImages(imageView.image!)
		}
		
		self.dismissViewControllerAnimated(true, completion: nil)
		cancelCamera(self)
	}
	
	func imagePickerControllerCancelled() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func capture(sender: UIButton) {
		//self.takePicture()
		self.fastCamera!.takePicture()
		
		downloadToCameraRoll = true
		
		updateThumbnail()
	}
	
	func updateThumbnail(){
		let image = UIImage()
		
		thumbnailButton.setBackgroundImage(image, forState: .Normal)
		thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
		thumbnailButton.layer.borderWidth=1.0
		
	}
	@IBAction func toggleTorch(sender: UIButton) {
		print("toggle pressed", terminator: "")
		
		if self.fastCamera!.cameraFlashMode == FastttCameraFlashMode.On {
			self.fastCamera!.cameraFlashMode = FastttCameraFlashMode.Off
			
			self.flashButton.setImage(flashOff, forState: .Normal)
			
		}else if self.fastCamera?.cameraFlashMode == FastttCameraFlashMode.Off{
			self.fastCamera?.cameraFlashMode = FastttCameraFlashMode.Auto
			
			self.flashButton.setImage(flashAuto, forState: .Normal)
			
		}else{
			self.fastCamera?.cameraFlashMode = FastttCameraFlashMode.On
			self.flashButton.setImage(flashOn, forState: .Normal)
		}
		
	}
	
	//TO-DO: restriction through geotagged image
	func setLastPhoto(){
		let fetchOptions: PHFetchOptions = PHFetchOptions()
		
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
		
		if (fetchResult.lastObject != nil) {
			
			let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
			
			let sizeIM = CGSizeMake(50,50)
			PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: sizeIM , contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
				self.thumbnailButton.setBackgroundImage(result, forState: .Normal)
				self.thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
				self.thumbnailButton.layer.borderWidth = 1.0
				self.thumbnailButton.layer.cornerRadius = 5
			}
			
		}
	}
	
	@IBAction func cancelCamera(sender: AnyObject) {
		
		print("here on cancel")
		self.dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	
	func uploadImages(uImage: UIImage)
	{
		print("------------------\nUPLOAD CANVAS\n----------------------------------------\n")
		
		if NetworkAvailable.networkConnection() == true {
			autoreleasepool({ () -> () in
				let imageData = compressImage(uImage, shrinkRatio: 1.0)
				let imageFile = PFFile(name: "image.png", data: imageData)
				
				
				let thumbnailData = compressImage(cropToSquare(image: uImage), shrinkRatio: 0.5)
				let thumbnailFile = PFFile(name: "image.png", data: thumbnailData)
				
				
				//Upload photos to database
				let photo = PFObject(className: "Photo")
				photo["caption"] = "Camera roll upload"
				photo["image"] = imageFile
				photo["thumbnail"] = thumbnailFile
				photo["upvoteCount"] = 1
				photo["usersLiked"] = [PFUser.currentUser()!.username!]
				photo["uploader"] = PFUser.currentUser()!
				photo["uploaderName"] = PFUser.currentUser()!.username!
				photo["flagged"] = false
				photo["reviewed"] = false
				photo["blocked"] = false
				photo["reporter"] = ""
				photo["reportMessage"] = ""
				photo["event"] = PFObject.init(withoutDataWithClassName: "Event", objectId: self.event!.objectId!);
				
				
				let photoACL = PFACL(user: PFUser.currentUser()!)
				photoACL.setPublicWriteAccess(true)
				photoACL.setPublicReadAccess(true)
				photo.ACL = photoACL
				
				
				let query2 = PFQuery(className: "EventAttendance")
				query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
				query2.whereKey("eventID", equalTo: event!.objectId!)
				
				//var photoObjectList = query2.findObjects()
				query2.findObjectsInBackgroundWithBlock({ (objs:[AnyObject]?, error:NSError?) -> Void in
					if (objs != nil && objs!.count != 0) {
						let photoObject = objs!.first as! PFObject
						
						photoObject.addUniqueObject(thumbnailFile, forKey:"photosUploaded")
						photoObject.addUniqueObject(thumbnailFile, forKey: "photosLiked")
						
						let queryEvent = PFQuery(className: "Event")
						queryEvent.whereKey("objectId", equalTo: self.event!.objectId!)
						//var objects = queryEvent.findObjects()
						queryEvent.findObjectsInBackgroundWithBlock({ (sobjs:[AnyObject]?, error:NSError?) -> Void in
							
							if (sobjs != nil && sobjs!.count != 0) {
								let eventObject = sobjs!.first as! PFObject
								
								let relation = eventObject.relationForKey("photos")
								
								//photo.save()
								photo.saveInBackgroundWithBlock({ (valid:Bool, error:NSError?) -> Void in
									if valid {
										relation.addObject(photo)
										photoObject.addUniqueObject(photo.objectId!, forKey: "photosUploadedID")
										photoObject.addUniqueObject(photo.objectId!, forKey: "photosLikedID")
									}
									//issue
									eventObject.saveInBackground()
									
									//issue
									photoObject.saveInBackgroundWithBlock({ (completed, error) -> Void in
										BFDataProcessor.sharedProcessor.processPhotos([photo], completion: { () -> Void in
											print("Photo stored in coredata..");
											let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
											dispatch_after(delayTime, dispatch_get_main_queue()) {
												NSNotificationCenter.defaultCenter().postNotificationName("camera-photo-uploaded", object: photo)
											}
										})
									})
								})
								
							} else {
								self.displayNoInternetAlert()
							}
						})
					}
					else {
						self.displayNoInternetAlert()
						print("Object Issue")
					}
					
				})
				
				
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.cancelCamera(self)
				})
			})
		} else {
			displayNoInternetAlert()
		}
		
	}
	
	func compressImage(image:UIImage, shrinkRatio: CGFloat) -> NSData {
		var imageHeight:CGFloat = image.size.height
		var imageWidth:CGFloat = image.size.width
		let maxHeight:CGFloat = 3264 * shrinkRatio//2272 * shrinkRatio//1136.0 * shrinkRatio
		let maxWidth:CGFloat = 1838 * shrinkRatio//1280 * shrinkRatio//640.0 * shrinkRatio
		var imageRatio:CGFloat = imageWidth/imageHeight
		let scalingRatio:CGFloat = maxWidth/maxHeight
		
		//lowest quality rating with acceptable encoding
		var quality:CGFloat = 0.7
		
		if (imageHeight > maxHeight || imageWidth > maxWidth){
			if(imageRatio < scalingRatio){
				/* To ensure aspect ratio is maintained adjust
				witdth of image in relation to scaling height */
				imageRatio = maxHeight / imageHeight;
				imageWidth = imageRatio * imageWidth;
				imageHeight = maxHeight;
			}
			else if(imageRatio > scalingRatio){
				/* To ensure aspect ratio is maintained adjust
				height of image in relation to scaling width */
				imageRatio = maxWidth / imageWidth;
				imageHeight = imageRatio * imageHeight;
				imageWidth = maxWidth;
			}
			else{
				/* If image is equivalent to scaling ratio
				image should not be compressed any further
				scaled down to max resolution*/
				imageHeight = maxHeight;
				imageWidth = maxWidth;
				quality = 1;
			}
		}
		
		let rect = CGRectMake(0.0, 0.0, imageWidth, imageHeight);
		//bit-map based graphic context and set the boundaries of still image
		UIGraphicsBeginImageContext(rect.size);
		image.drawInRect(rect)
		let imageCompressed = UIGraphicsGetImageFromCurrentImageContext();
		let imageData = UIImageJPEGRepresentation(imageCompressed, quality);
		UIGraphicsEndImageContext();
		
		return imageData!;
		
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
	// MARK: - FastttCameraDelegate
	func cameraController(cameraController: FastttCameraInterface!, didFinishCapturingImage capturedImage: FastttCapturedImage!) {
		
		/**
		*  Here, capturedImage.fullImage contains the full-resolution captured
		*  image, while capturedImage.rotatedPreviewImage contains the full-resolution
		*  image with its rotation adjusted to match the orientation in which the
		*  image was captured.
		*/
		
	}
	
	func cameraController(cameraController: FastttCameraInterface!, didFinishScalingCapturedImage capturedImage: FastttCapturedImage!) {
		
		/**
		*  Here, capturedImage.scaledImage contains the scaled-down version
		*  of the image.
		*/
	}
	
	func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
		/**
		*  Here, capturedImage.fullImage and capturedImage.scaledImage have
		*  been rotated so that they have image orientations equal to
		*  UIImageOrientationUp. These images are ready for saving and uploading,
		*  as they should be rendered more consistently across different web
		*  services than images with non-standard orientations.
		*/
		
		autoreleasepool { () -> () in
			
			if let wnd = self.fastCamera?.view {
				
				let v = UIView(frame: wnd.bounds)
				v.backgroundColor = UIColor.whiteColor()
				v.alpha = 1.0
				
				wnd.addSubview(v)
				
				UIView.animateWithDuration(1500, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
					v.alpha = 1.0
					}, completion: { (finished:Bool) -> Void in
						print("inside")
						v.removeFromSuperview()
				})
				
				
				let v2 = UIView(frame: wnd.bounds)
				v2.backgroundColor = UIColor.whiteColor()
				v2.alpha = 1
				
				UIView.animateWithDuration(1500, delay: 1500, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
					v2.alpha = 1.0
					}, completion: { (finished:Bool) -> Void in
						print("outside")
						v2.removeFromSuperview()
				})
				
				
			}
			
			var imageViewContent = UIImage()
			
			//image stored in local variable to contain lifespan in method
			
			let imageShortLife:UIImage = capturedImage.scaledImage
			var imageShortLife_Corrected = UIImage()
			if imageShortLife.imageOrientation != UIImageOrientation.Up{
				
				imageShortLife_Corrected = UIImage(CGImage: imageShortLife.CGImage!, scale: 0.0, orientation: capturedImage.capturedImageOrientation)
			}else{
				imageShortLife_Corrected = imageShortLife
			}
			
			
			print("\(capturedImage.capturedImageOrientation)", terminator: "")
			
			imageViewContent = imageShortLife
			//picker.dismissViewControllerAnimated(true, completion: nil)
			
			//Retake and crop options------------------------------------------------------------------------
			let previewViewController = PreviewViewController.sharedPreview
			previewViewController.event = event
			previewViewController.cropCompletionHandler = {
				imageViewContent = $0!
				previewViewController.dismissViewControllerAnimated(true, completion: nil)
				
				
				let imageView = UIImageView(image: imageViewContent)
				imageView.contentMode = UIViewContentMode.ScaleAspectFit
				//self.uploadImages(imageView.image!)
				
				
				self.dismissViewControllerAnimated(true, completion: nil)
				UIApplication.sharedApplication().statusBarHidden = true
				
				
				
			}
			previewViewController.cancelCompletionHandler = {
				//retake image
				
				//self.presentViewController(picker, animated:true, completion:{})
				self.setLastPhoto()
				self.updateThumbnail()
				self.flashButton.hidden = false
				self.setLastPhoto()
				self.updateThumbnail()
				UIApplication.sharedApplication().statusBarHidden = true
				
				
			}
			
			if self.fastCamera?.cameraDevice == FastttCameraDevice.Front {
				
				let orientation = UIDevice.currentDevice().orientation
				
				if orientation == UIDeviceOrientation.Portrait{
					previewViewController.imageToCrop = imageViewContent
					
				} else if orientation == UIDeviceOrientation.LandscapeLeft{
					
					let t:CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
					var inputImage = CIImage(image: imageViewContent)
					
					
					inputImage = inputImage!.imageByApplyingTransform(t)
					let cgImage = self.context.createCGImage(inputImage!, fromRect: inputImage!.extent)
					imageViewContent = UIImage(CGImage: cgImage)
					
					previewViewController.imageToCrop = imageViewContent
					
				} else if orientation == UIDeviceOrientation.LandscapeRight{
					
					let t:CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
					var inputImage = CIImage(image: imageViewContent)
					
					
					inputImage = inputImage!.imageByApplyingTransform(t)
					let cgImage = self.context.createCGImage(inputImage!, fromRect: inputImage!.extent)
					imageViewContent = UIImage(CGImage: cgImage)
					
					previewViewController.imageToCrop = imageViewContent
					
				}
				previewViewController.imageToCrop = imageViewContent
			}
			else{
				let orientation = UIDevice.currentDevice().orientation
				
				if orientation == UIDeviceOrientation.Portrait{
					previewViewController.imageToCrop = imageViewContent
					
				} else if orientation == UIDeviceOrientation.LandscapeLeft{
					
					let t:CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
					var inputImage = CIImage(image: imageViewContent)
					
					
					inputImage = inputImage!.imageByApplyingTransform(t)
					let cgImage = self.context.createCGImage(inputImage!, fromRect: inputImage!.extent)
					imageViewContent = UIImage(CGImage: cgImage)
					
					previewViewController.imageToCrop = imageViewContent
					
				} else if orientation == UIDeviceOrientation.LandscapeRight{
					
					let t:CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
					var inputImage = CIImage(image: imageViewContent)
					
					
					inputImage = inputImage!.imageByApplyingTransform(t)
					let cgImage = self.context.createCGImage(inputImage!, fromRect: inputImage!.extent)
					imageViewContent = UIImage(CGImage: cgImage)
					
					previewViewController.imageToCrop = imageViewContent
					
				}
				previewViewController.imageToCrop = imageViewContent
				
			}
			
			//previewViewController.eventId = self.event!.objectId!
			//previewViewController.eventTitle = self.event!.name!
			previewViewController.downloadToCameraRoll = downloadToCameraRoll
			
			self.presentViewController(previewViewController, animated: true, completion: nil);
			setLastPhoto()
			updateThumbnail()
			UIApplication.sharedApplication().statusBarHidden = false
			
		}
		
	}
	
	func cameraController(cameraController: FastttCameraInterface!, didReceiveRawBuffer imageData: [NSObject : AnyObject]!) {}
	
	
	func displayNoInternetAlert() {
		let alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
		self.presentViewController(alert, animated: true, completion: nil)
		print("no internet")
	}
	func filterSwipeGesture(gesture: UIGestureRecognizer) {
		//		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
		//			//            self.currentFilter = self.currentFilter.nextFilter
		//			//            self.fastCamera.filterImage = self.currentFilter.filterImage
		//
		//
		//		}
		
	}
	
	lazy var filterNames: [String] = {
		return ["FastttCameraFilterRetro","FastttCameraFilterHighContrast","FastttCameraFilterSepia","FastttCameraFilterBW","FastttCameraFilterNone"]
		}()
	
	
	func handleSwipes(sender:UISwipeGestureRecognizer) {
		if (sender.direction == .Left) {
			print("Left \(filterCount)")
			if(filterCount>0){
				filterCount -= 1
				// var filterName = filterNames[filterCount]
				
				//  self.currentFilter = self.currentFilter.nextFilter()
				//  self.fastCamera.filterImage = self.currentFilter.filterImage
			}else{
				
			}
			
		}
		
		if (sender.direction == .Right) {
			if(filterCount<filterNames.count-1){
				print("Right \(filterCount)")
				filterCount += 1
				// var filterName = filterNames[filterCount]
			}
		}
	}
	func changeFilter() {
		print("switch filter", terminator: "");
		self.currentFilter = self.currentFilter?.nextFilter()
		
		self.fastCamera?.filterImage = self.currentFilter?.filterImage
	}
	
}