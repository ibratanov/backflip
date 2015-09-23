//
//  PreviewViewController.swift
//  Backflip
//
//  Created by MWars on 2015-06-15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class PreviewViewController: UIViewController, UIScrollViewDelegate {
    var filterCount = 0;
	
	static let sharedPreview : PreviewViewController = PreviewViewController(nibName: "PreviewViewController", bundle: nil)
	
    // Title passed from previous VC
	var event : Event?

    var eventLocation: PFGeoPoint?
    var downloadToCameraRoll: Bool?
    var imageReady: Bool?
    
    //---------Filters
    lazy var context: CIContext = {
        return CIContext(options: nil)
        }()
    
    var filter: CIFilter!
    
    @IBOutlet weak var imageLoad: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var referenceView: UIView!

    @IBOutlet weak var cropOpeningView: UIView!
    
    typealias CropCompletionHandlerType = (UIImage?) -> ()
    var cropCompletionHandler: CropCompletionHandlerType?
    
    typealias CancelCompletionHandlerType = () -> ()
    var cancelCompletionHandler: CancelCompletionHandlerType?
    
    //Image attributes
    var imageToCrop: UIImage? {
        didSet {
            if imageView != nil && imageToCrop != nil {
                imageView.image = imageToCrop!
                imageView.setNeedsUpdateConstraints()
            }
        }
    }
    
    private let NibName = "PreviewViewController"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: NibName, bundle: nil);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
	
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    func displayNoInternetAlert() {
        let alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to access content.")
        self.presentViewController(alert, animated: true, completion: nil)
        print("no internet")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: ("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: ("handleSwipes:"))
        
        if(self.imageToCrop != nil ){imageView.image = resizeImage(imageToCrop!) }
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    

    //, newHeight: CGFloat, newWidth: CGFloat
    func resizeImage(image: UIImage) -> UIImage {
        let screenH =         UIScreen.mainScreen().bounds.height

        let screenW =         UIScreen.mainScreen().bounds.width

        let newHeight:CGFloat = screenH * 3.757
        //let newHeight:CGFloat = referenceView.bounds.height * 3.757

        print("\(newHeight)+\(screenH)", terminator: "")
        
       // let newWidth:CGFloat = 2134
        let newWidth:CGFloat = screenW * 6.796

        //let newWidth:CGFloat = referenceView.bounds.width * 6.796
        print("-------\(newWidth)+\(screenW)", terminator: "")
        
        if(image.size.width > image.size.height){
            
            let scale = newHeight / image.size.height
            let newWidthI = image.size.width * scale
            UIGraphicsBeginImageContext(CGSizeMake(newWidthI, newHeight))
            image.drawInRect(CGRectMake(0, 0, newWidthI, newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        } else if(image.size.height > image.size.width){
            
            let scale = newWidth / image.size.width
            let newHeightI = image.size.height * scale
            UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeightI))
            image.drawInRect(CGRectMake(0, 0, newWidth, newHeightI))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
            
        }else{
            
            let scale = newHeight / image.size.height
            let newWidthI = image.size.width * scale
            UIGraphicsBeginImageContext(CGSizeMake(newWidthI, newHeight))
            image.drawInRect(CGRectMake(0, 0, newWidthI, newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
            
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        let cropDimension = cropOpeningView.bounds.size.minDimension()
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.15
        
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        
        let horizontalInset = (referenceView.bounds.width - cropDimension)/2 - scrollView.frame.origin.x
        let verticalInset = (referenceView.bounds.height - cropDimension)/2 - scrollView.frame.origin.y
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset)
        
        self.view.layoutIfNeeded()
        
        super.viewDidLayoutSubviews()
        
             }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        if(self.imageToCrop != nil ){imageView.image = resizeImage(imageToCrop!) }
            }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //imageToCrop = nil
        
    }
    
    override func viewWillAppear(animated: Bool)
	{
		#if FEATURE_GOOGLE_ANALYTICS
			let tracker = GAI.sharedInstance().defaultTracker
			tracker.set(kGAIScreenName, value: "Preview Screen")
			tracker.set("&uid", value: PFUser.currentUser()?.objectId)

			let builder = GAIDictionaryBuilder.createScreenView()
			tracker.send(builder.build() as [NSObject : AnyObject])
		#endif
    }
    
    @IBAction func cropButtonPressed(sender: AnyObject) {
        let cropDimension = cropOpeningView.bounds.size.minDimension()
        let contentRectVisibleInScrollView = CGRect(
            origin: CGPoint(x: scrollView.contentOffset.x + scrollView.contentInset.left,
                y: scrollView.contentOffset.y + scrollView.contentInset.top),
            size: CGSize(width: cropDimension, height: cropDimension))
        
        let imageViewRect = contentRectVisibleInScrollView.scaledBy(1/scrollView.zoomScale)
        
        self.dismissViewControllerAnimated(true, completion: {
            if self.cropCompletionHandler != nil {

                self.cropCompletionHandler!(self.imageView.image?.croppedToRect(imageViewRect))
                
            }
        })
    //------------------UPLOAD CANVAS----------------------------------------
        
        if NetworkAvailable.networkConnection() == true {

		autoreleasepool({ () -> () in
			let capturedImage = self.imageView.image?.croppedToRect(imageViewRect) as UIImage!
			if (downloadToCameraRoll!) {
				UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
			}
			
			
			let imageData = compressImage(capturedImage, shrinkRatio: 1.0)
			let imageFile = PFFile(name: "image.png", data: imageData)
			
			let thumbnailData = compressImage(capturedImage, shrinkRatio: 0.5)
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
					
					//TODO: Investigate issue with multi-flagged photos
					//                    photoObject.addUniqueObject(thumbnailFile, forKey:"photosUploaded")
					//                    photoObject.addUniqueObject(thumbnailFile, forKey: "photosLiked")
					
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
									photoObject.addUniqueObject(imageFile, forKey:"photosUploaded")
									photoObject.addUniqueObject(imageFile, forKey: "photosLiked")
									
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
        var quality:CGFloat = 0.4
		
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
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        imageView.image = nil

        imageToCrop = nil

        self.dismissViewControllerAnimated(true, completion: cancelCompletionHandler)
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //----------Filters
	
    func showOriginalImage() {
        self.imageView.image = resizeImage(imageToCrop!) //imageToCrop!
    }
    
    func outputImage() {
		
		autoreleasepool { () -> () in
			let inputImage = CIImage(image: imageToCrop!)
			
			filter.setValue(inputImage, forKey: kCIInputImageKey)
			
			var outputImage =  filter.outputImage
			var t: CGAffineTransform!
			
			let orientation = UIDevice.currentDevice().orientation
			t = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
			
			//t = CGAffineTransformMakeRotation(0)
			
			outputImage = outputImage!.imageByApplyingTransform(t)
			
			let cgImage = self.context.createCGImage(outputImage!, fromRect: outputImage!.extent)
			//ciImage = outputImage
			let ImageC = UIImage(CGImage: cgImage)
			
			imageView.image = resizeImage(ImageC) //imageToCrop!
		}

    }
    lazy var filterNames: [String] = {
        return ["CIPhotoEffectNoir","CIPhotoEffectChrome","CIColorInvert","CIPhotoEffectMono","CIPhotoEffectInstant","CIPhotoEffectTransfer","CIPhotoEffectFade","CIPhotoEffectTonal","CIPhotoEffectTransfer","CIPhotoEffectProcess"]
        }()

    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            print("Left \(filterCount)")
            if(filterCount>0){
                filterCount -= 1
            let filterName = filterNames[filterCount]
            filter = CIFilter(name: filterName)
                outputImage()
            }else{
                showOriginalImage()
            }
            
        }
        
        if (sender.direction == .Right) {
            if(filterCount<filterNames.count-1){
            print("Right \(filterCount)")
                filterCount += 1
            let filterName = filterNames[filterCount]
            filter = CIFilter(name: filterName)
                outputImage()
            }
        }
    }

}
