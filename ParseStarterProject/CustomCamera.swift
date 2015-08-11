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

class CustomCamera : UIImagePickerController, UIImagePickerControllerDelegate,UINavigationControllerDelegate ,BFCImagePickerControllerDelegate {
    
//------------------Camera Att.-----------------
    var flashOff = UIImage(named:"flash-icon-large") as UIImage!
    var flashOn = UIImage(named:"flashon-icon-large") as UIImage!
    var loopAllImagesBool = false
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    var imageViewContent = UIImage()
    var overlayView: UIView?
    var image = UIImage()
    var picker = UIImagePickerController()
    var zoomImage = (camera: true, display: true)
    var newMedia: Bool = true

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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
    
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name:  "AVSystemController_SystemVolumeDidChangeNotification", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name: "_UIApplicationVolumeUpButtonDownNotification", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "capture:", name: "_UIApplicationVolumeDownButtonDownNotification", object: nil)
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
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                        println("Button capture")
                        
                        //primary delegate for the picker
                        self.picker.delegate = self
                        
                        self.picker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                        self.picker.sourceType = .Camera
                        self.picker.mediaTypes = [kUTTypeImage]
                        self.picker.allowsEditing = false
                        self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0)
                        self.picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, 71.0), 1.333333, 1.333333)
                        // resize
                        if (self.zoomImage.camera) {
                            var screenBounds: CGSize = UIScreen.mainScreen().bounds.size
                            var cameraAspectRatio: CGFloat = 4.0/3.0
                            var cameraViewHeight = screenBounds.width * cameraAspectRatio
                            var scale = screenBounds.height / cameraViewHeight
                            self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - cameraViewHeight) / 2.0)
                            self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, scale, scale)
                            self.zoomImage.camera = false
                        }
                        
                        // custom camera overlayview
                        self.picker.showsCameraControls = false
                        NSBundle.mainBundle().loadNibNamed("OverlayView", owner:self, options:nil)
                        self.overlayView!.frame = self.picker.cameraOverlayView!.frame
                        self.picker.cameraOverlayView = self.overlayView
                        self.overlayView = nil
                        
                        self.presentViewController(self.picker, animated:true, completion:{})
                        self.setLastPhoto()
                        self.updateThumbnail()
                        self.newMedia = true
                    } else {
                        if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                            var picker = UIImagePickerController()
                            picker.delegate = self;
                            picker.sourceType = .PhotoLibrary
                            picker.mediaTypes = [kUTTypeImage]
                            picker.allowsEditing = false
                            
                            self.presentViewController(picker, animated:true, completion:{})
                            
                            self.newMedia = false
                            self.setLastPhoto()
                            self.updateThumbnail()
                        }
                    }
                    
                    self.testCalled()
                    
                    self.setLastPhoto()
                    self.updateThumbnail()
                    
                    
                }
            } else {
                
                println(error)
            }
        })
    } else {
        displayNoInternetAlert() }
     
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

@IBAction func loadFromLibrary(sender: AnyObject) {
    var picker = UIImagePickerController()
    picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
    picker.delegate = self
    self.presentViewController(picker, animated: true, completion: nil)
    
}


func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
{
    //image stored in local variable to contain lifespan in method
    var imageShortLife:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    self.imageViewContent = imageShortLife
    picker.dismissViewControllerAnimated(true, completion: nil)
    
    //Retake and crop options------------------------------------------------------------------------
    let previewViewController = PreviewViewController(nibName: "PreviewViewController", bundle: nil);
    previewViewController.cropCompletionHandler = {
        self.imageViewContent = $0!
        previewViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    previewViewController.cancelCompletionHandler = {
        //retake image
        
        self.presentViewController(picker, animated:true, completion:{})
        self.setLastPhoto()
        self.updateThumbnail()
        self.flashButton.hidden = false
        self.setLastPhoto()
        self.updateThumbnail()
        
    }
    
    if self.picker.cameraDevice == UIImagePickerControllerCameraDevice.Front{
        previewViewController.imageToCrop = imageViewContent
        //UIImage(CGImage: imageViewContent.CGImage, scale: 1.0, orientation: .LeftMirrored)
        //UIImage(CGImage: initialImage.CGImage, scale: 1, orientation: initialImage.imageOrientation)!
    }
    else{
        previewViewController.imageToCrop = imageViewContent
    }
    
    previewViewController.eventId = self.eventId
    previewViewController.eventTitle = self.eventTitle
    previewViewController.downloadToCameraRoll = downloadToCameraRoll
    
    self.presentViewController(previewViewController, animated: true, completion: nil);
    setLastPhoto()
    updateThumbnail()
    
}


func imagePickerControllerDidCancel(picker: UIImagePickerController){
    
    picker.dismissViewControllerAnimated(true, completion: nil)
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
    //TO-DO: add transition when reversed
    if self.picker.cameraDevice == UIImagePickerControllerCameraDevice.Front{
        
        var screenBounds: CGSize = UIScreen.mainScreen().bounds.size
        var cameraAspectRatio: CGFloat = 4.0/3.0
        var cameraViewHeight = screenBounds.width * cameraAspectRatio
        var scale = screenBounds.height / cameraViewHeight
        picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - cameraViewHeight) / 2.0)
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale)
        self.zoomImage.camera = false
        
        
        UIView.transitionWithView(self.picker.view, duration: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.TransitionFlipFromLeft , animations: { () -> Void in
            self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            }, completion: nil)
        
        self.flashButton.hidden = false
    }else{
        
        //----------------------------------------------------------------------------
        self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, -5.0)
        self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, 1.0, 1.0)
        
        // resize
        if (zoomImage.camera) {
            self.zoomImage.camera = false
        }
        //----------------------------------------------------------------------------
        
        UIView.transitionWithView(self.picker.view, duration: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.TransitionFlipFromRight , animations: { () -> Void in
            self.picker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }, completion: nil)
        
        self.flashButton.hidden = true
    }
}

@IBAction func showCameraRoll(sender: UIButton) {
    picker.dismissViewControllerAnimated(true, completion: nil)
    
    //        downloadToCameraRoll = false
    //
    //        var controller = UIImagePickerController()
    //        controller.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
    //        controller.mediaTypes = [kUTTypeImage]
    //        controller.delegate = self
    //        self.presentViewController(controller, animated:true, completion:nil)
    
    let pickerController = BFCImagePickerController()
    pickerController.pickerDelegate = self
    self.presentViewController(pickerController, animated: true) {}
}

//********call back functions for ^^^^**********
func imagePickerControllerDidSelectedAssets(assets: [BFCAsset]!) {
    //Send assets to parse
    for (index, asset) in enumerate(assets) {
        let imageView = UIImageView(image: asset.fullScreenImage)
        //----->imageView.contentMode = UIViewContentMode.ScaleAspectFit
        uploadImages(imageView.image!)
    }
    self.dismissViewControllerAnimated(true, completion: nil)
}

func imagePickerControllerCancelled() {
    self.dismissViewControllerAnimated(true, completion: nil)
}


@IBAction func capture(sender: UIButton) {
    picker.takePicture()
    
    downloadToCameraRoll = true
    
    updateThumbnail()
}

func updateThumbnail(){
    thumbnailButton.setBackgroundImage(image, forState: .Normal)
    thumbnailButton.layer.borderColor = UIColor.whiteColor().CGColor
    thumbnailButton.layer.borderWidth=1.0
    
}
@IBAction func toggleTorch(sender: UIButton) {
    if self.picker.cameraFlashMode == UIImagePickerControllerCameraFlashMode.On{
        self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
        
        self.flashButton.setImage(flashOff, forState: .Normal)
        
    }else{
        self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
        self.flashButton.setImage(flashOn, forState: .Normal)
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
    picker.dismissViewControllerAnimated(true, completion: nil)
    
}


func uploadImages(uImage: UIImage){
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
        query2.whereKey("eventID", equalTo: eventId!)
        
        //var photoObjectList = query2.findObjects()
        var photoObjectList: Void = query2.findObjectsInBackgroundWithBlock({ (objs:[AnyObject]?, error:NSError?) -> Void in
            if (objs != nil && objs!.count != 0) {
                var photoObject = objs!.first as! PFObject
                
                photoObject.addUniqueObject(thumbnailFile, forKey:"photosUploaded")
                photoObject.addUniqueObject(thumbnailFile, forKey: "photosLiked")
                
                var queryEvent = PFQuery(className: "Event")
                queryEvent.whereKey("objectId", equalTo: self.eventId!)
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
                            photoObject.saveInBackground()
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
    var quality:CGFloat = 0.3
    
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
    
    func displayNoInternetAlert() {
        var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }

}