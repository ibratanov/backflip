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

class CustomCamera : UIViewController ,BFCImagePickerControllerDelegate, FastttCameraDelegate {
    
    //------------------FastttCamera----------------
    //var fastCamera = FastttFilterCamera()
    var fastCamera = FastttFilterCamera()
    
   // var currentFilter = ExampleFilter()
   // _currentFilter = [ExampleFilter filterWithType:FastttCameraFilterRetro];
   // _fastCamera = [FastttFilterCamera cameraWithFilterImage:self.currentFilter.filterImage];
	
	//------------------Camera Att.-----------------
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var previewScreenView: UIView!
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet var eventNameLabel : UILabel?
    
    
	var flashOff = UIImage(named:"flash-icon-large") as UIImage!
	var flashOn = UIImage(named:"flashon-icon-large") as UIImage!
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
	// Title and ID of event passed from previous VC, based on selected row
	var eventId : String?
	var eventTitle: String?
	// Keeps track of photo source and only downloads newly taken images
	var downloadToCameraRoll = true
    
    //var fastFilter = FastttFilter()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.sharedApplication().statusBarHidden = true
		
		self.eventNameLabel?.text = self.eventTitle
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: ("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: ("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
		//self.currentFilter.filterType = FastttFilterType.CameraFilterRetro
        //self.fastCamera = FastttFilterCamera(filterImage: self.currentFilter.filterImage)
        //self.fastCamera = FastttFilterCamera(filterImage: UIImage(named: "SepiaFilter"))
        self.fastCamera.delegate = self
        self.fastCamera.willMoveToParentViewController(self)
        self.fastCamera.beginAppearanceTransition(true, animated: false)
        self.addChildViewController(self.fastCamera)
        self.view.insertSubview(self.fastCamera.view, belowSubview: previewScreenView)
        self.fastCamera.didMoveToParentViewController(self)
        self.fastCamera.endAppearanceTransition()
        self.fastCamera.view.frame = self.view.frame
        //self.fastCamera.cameraDevice = FastttCameraDevice.Rear
        //self.fastCamera.filterImage = FastttCameraFilterHighContrast
        
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
//						self.fullScreen = false
//						self.posted = true
//						
//						self.testCalled()
//						
//						self.setLastPhoto()
//						self.updateThumbnail()
						
					}
				} else {
					
					println(error)
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
		var alert:UIAlertView = UIAlertView()
		alert.title = "Saved!"
		alert.message = "Saved to Camera Roll"
		alert.delegate = self
		alert.addButtonWithTitle("Ok")
		alert.show()
	}

//	
//	
//	func imagePickerControllerDidCancel(picker: UIImagePickerController){
//		
//		picker.dismissViewControllerAnimated(true, completion: nil)
//	}
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
	
	func cropToSquare(image originalImage: UIImage) -> UIImage {
		// Get image and measurements
		let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
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
		let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
		
		//Define original orientation
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
		
		var status : AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
		if (status == AVAuthorizationStatus.Authorized) {
			println("authorized")
		} else if(status == AVAuthorizationStatus.Denied){
			var alert:UIAlertView = UIAlertView()
			alert.title = "Camera Disabled"
			alert.message = "Please enable camera access in the iOS settings for Backflip or upload from your camera roll."
			alert.delegate = self
			alert.addButtonWithTitle("Ok")
			alert.show()
		} else if(status == AVAuthorizationStatus.Restricted){
			var alert:UIAlertView = UIAlertView()
			alert.title = "Camera Disabled"
			alert.message = "Please enable camera access in the iOS settings for Backflip or upload from your camera roll."
			alert.delegate = self
			alert.addButtonWithTitle("Ok")
			alert.show()
		}
	}
	
	@IBAction func reverseCamera(sender: UIButton) {
        var cameraDevice: FastttCameraDevice
        switch (self.fastCamera.cameraDevice) {
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
            self.fastCamera.cameraDevice = cameraDevice
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
		for (index, asset) in enumerate(assets) {
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
        self.fastCamera.takePicture()
		
		downloadToCameraRoll = true
		
		updateThumbnail()
	}
	
	func updateThumbnail(){
        var image = UIImage()

		thumbnailButton.setBackgroundImage(image, forState: .Normal)
		thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
		thumbnailButton.layer.borderWidth=1.0
		
	}
	@IBAction func toggleTorch(sender: UIButton) {
        print("toggle pressed")
        var torchMode = FastttCameraFlashMode.On
        switch (self.fastCamera.cameraFlashMode) {
        case FastttCameraFlashMode.On:
            torchMode = FastttCameraFlashMode.Off
            self.flashButton.setImage(flashOff, forState: .Normal)
            
            break
        //case FFastttCameraFlashModeOn:
        default:
            torchMode = FastttCameraFlashMode.On
            self.flashButton.setImage(flashOn, forState: .Normal)
            break
        }

    }
	
	//TO-DO: restriction through geotagged image
	func setLastPhoto(){
		var fetchOptions: PHFetchOptions = PHFetchOptions()
		
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		var fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
		
		if (fetchResult.lastObject != nil) {
			
			var lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
			
			var sizeIM = CGSizeMake(50,50)
			PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: sizeIM , contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
				self.thumbnailButton.setBackgroundImage(result, forState: .Normal)
				self.thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
				self.thumbnailButton.layer.borderWidth = 1.0
				self.thumbnailButton.layer.cornerRadius = 5
			}
			
		}
	}
	
	@IBAction func cancelCamera(sender: AnyObject) {
		
		println("here on cancel")
		self.dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	
	func uploadImages(uImage: UIImage)
	{
		println("------------------\nUPLOAD CANVAS\n----------------------------------------\n")
		
		    if NetworkAvailable.networkConnection() == true {
		
		        var capturedImage = uImage as UIImage!
		
		        var imageData = compressImage(uImage, shrinkRatio: 1.0)
		        var imageFile = PFFile(name: "image.png", data: imageData)
		
		
		
		        var thumbnailData = compressImage(cropToSquare(image: uImage), shrinkRatio: 0.5)
		        var thumbnailFile = PFFile(name: "image.png", data: thumbnailData)
		
		
		        //Upload photos to database
		        var photo = PFObject(className: "Photo")
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
		
		        var photoACL = PFACL(user: PFUser.currentUser()!)
		        photoACL.setPublicWriteAccess(true)
		        photoACL.setPublicReadAccess(true)
		        photo.ACL = photoACL
		
		
		        var query2 = PFQuery(className: "EventAttendance")
		        query2.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
		        query2.whereKey("eventID", equalTo: event!.objectId!)
		
		        //var photoObjectList = query2.findObjects()
		        var photoObjectList: Void = query2.findObjectsInBackgroundWithBlock({ (objs:[AnyObject]?, error:NSError?) -> Void in
		            if (objs != nil && objs!.count != 0) {
		                var photoObject = objs!.first as! PFObject
		
		                photoObject.addUniqueObject(thumbnailFile, forKey:"photosUploaded")
		                photoObject.addUniqueObject(thumbnailFile, forKey: "photosLiked")
		
		                var queryEvent = PFQuery(className: "Event")
		                queryEvent.whereKey("objectId", equalTo: self.event!.objectId!)
		                //var objects = queryEvent.findObjects()
		                var objects: Void = queryEvent.findObjectsInBackgroundWithBlock({ (sobjs:[AnyObject]?, error:NSError?) -> Void in
		
		                    if (sobjs != nil && sobjs!.count != 0) {
		                        var eventObject = sobjs!.first as! PFObject
		
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
										NSNotificationCenter.defaultCenter().postNotificationName("camera-photo-uploaded", object: photo)
									})
		                        })
		
		                    } else {
		                        self.displayNoInternetAlert()
		                    }
		                })
		            }
		            else {
		                self.displayNoInternetAlert()
		                println("Object Issue")
		            }
		
		        })
		
				
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.cancelCamera(self)
				})
				
		    } else {
		        displayNoInternetAlert()
		    }
		
	}
	
	func compressImage(image:UIImage, shrinkRatio: CGFloat) -> NSData {
		var imageHeight:CGFloat = image.size.height
		var imageWidth:CGFloat = image.size.width
		var maxHeight:CGFloat = 3264 * shrinkRatio//2272 * shrinkRatio//1136.0 * shrinkRatio
		var maxWidth:CGFloat = 1838 * shrinkRatio//1280 * shrinkRatio//640.0 * shrinkRatio
		var imageRatio:CGFloat = imageWidth/imageHeight
		var scalingRatio:CGFloat = maxWidth/maxHeight
		
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
		
		var rect = CGRectMake(0.0, 0.0, imageWidth, imageHeight);
		//bit-map based graphic context and set the boundaries of still image
		UIGraphicsBeginImageContext(rect.size);
		image.drawInRect(rect)
		var imageCompressed = UIGraphicsGetImageFromCurrentImageContext();
		let imageData = UIImageJPEGRepresentation(imageCompressed, quality);
		UIGraphicsEndImageContext();
		
		return imageData;
		
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - FastttCameraDelegate
    func cameraController(cameraController: FastttCameraInterface!, didFinishCapturingImage capturedImage: FastttCapturedImage!) {
    
        //        var imageViewContent = UIImage()
        //
        //		//image stored in local variable to contain lifespan in method
        //		var imageShortLife:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //		imageViewContent = imageShortLife
        //		//picker.dismissViewControllerAnimated(true, completion: nil)
        //
        //		//Retake and crop options------------------------------------------------------------------------
        //		var previewViewController = PreviewViewController(nibName: "PreviewViewController", bundle: nil);
        //		previewViewController.cropCompletionHandler = {
        //			imageViewContent = $0!
        //			previewViewController.dismissViewControllerAnimated(true, completion: nil)
        //
        //
        //			var imageView = UIImageView(image: imageViewContent)
        //			imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //			//self.uploadImages(imageView.image!)
        //
        //			picker.dismissViewControllerAnimated(true, completion: nil)
        //            UIApplication.sharedApplication().statusBarHidden = false
        //
        //
        //
        //		}
        //		previewViewController.cancelCompletionHandler = {
        //			//retake image
        //
        //			//self.presentViewController(picker, animated:true, completion:{})
        //			self.setLastPhoto()
        //			self.updateThumbnail()
        //			self.flashButton.hidden = false
        //			self.setLastPhoto()
        //			self.updateThumbnail()
        //            UIApplication.sharedApplication().statusBarHidden = false
        //
        //
        //		}
        //
        //		if self.cameraDevice == UIImagePickerControllerCameraDevice.Front{
        //            imageViewContent = UIImage(CGImage: imageViewContent.CGImage, scale: 1.0, orientation: .LeftMirrored)!
        //			previewViewController.imageToCrop = imageViewContent
        //			//UIImage(CGImage: initialImage.CGImage, scale: 1, orientation: initialImage.imageOrientation)!
        //		}
        //		else{
        //			previewViewController.imageToCrop = imageViewContent
        //		}
        //
        //		previewViewController.eventId = self.event!.objectId!
        //		// previewViewController.eventTitle = self.event!.name!
        //		previewViewController.downloadToCameraRoll = downloadToCameraRoll
        //		
        //		self.presentViewController(previewViewController, animated: true, completion: nil);
        //		setLastPhoto()
        //		updateThumbnail()
        //        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishScalingCapturedImage capturedImage: FastttCapturedImage!) {}
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {}
    
    func cameraController(cameraController: FastttCameraInterface!, didReceiveRawBuffer imageData: [NSObject : AnyObject]!) {}

	
	func displayNoInternetAlert() {
		var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
		self.presentViewController(alert, animated: true, completion: nil)
		println("no internet")
	}
    func filterSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            self.currentFilter = self.currentFilter.nextFilter
//            self.fastCamera.filterImage = self.currentFilter.filterImage

        
            }
        
    }
	
    lazy var filterNames: [String] = {
        return ["FastttCameraFilterRetro","FastttCameraFilterHighContrast","FastttCameraFilterSepia","FastttCameraFilterBW","FastttCameraFilterNone"]
        }()
    
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            println("Left \(filterCount)")
            if(filterCount>0){
                filterCount -= 1
                var filterName = filterNames[filterCount]
                
                
              //  self.currentFilter = self.currentFilter.nextFilter()
              //  self.fastCamera.filterImage = self.currentFilter.filterImage
            }else{
                
            }
            
        }
        
        if (sender.direction == .Right) {
            if(filterCount<filterNames.count-1){
                println("Right \(filterCount)")
                filterCount += 1
                var filterName = filterNames[filterCount]
            }
        }
    }
    

}