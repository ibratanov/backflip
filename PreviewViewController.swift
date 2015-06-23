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
    
    // Title passed from previous VC
    var eventId : String?
    var eventTitle : String?
    var eventLocation: PFGeoPoint?
    var downloadToCameraRoll: Bool?
    
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
            if imageView != nil {
                imageView.image = imageToCrop!
                imageView.setNeedsUpdateConstraints()
            }
        }
    }
    
    private let NibName = "PreviewViewController"
    
    required init(coder aDecoder: NSCoder) {
        super.init(nibName: NibName, bundle: nil);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert({ self.imageToCrop != nil }(), "image not set before PreviewViewController's view is loaded.")
        
        imageView.image = resizeImage(imageToCrop!, newHeight: 2134, newWidth: 2134) //imageToCrop!
    }
    
     func resizeImage(image: UIImage, newHeight: CGFloat, newWidth: CGFloat) -> UIImage {
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
        var capturedImage = self.imageView.image?.croppedToRect(imageViewRect) as UIImage!
        
        if (downloadToCameraRoll!) {
            UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
        }
        
        var imageData = compressImage(capturedImage, shrinkRatio: 1.0)
        var imageFile = PFFile(name: "image.png", data: imageData)
        
        var thumbnailData = compressImage(capturedImage, shrinkRatio: 0.5)
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
        var photoObject = query2.findObjects()!.first as! PFObject

        
        photoObject.addUniqueObject(thumbnailFile, forKey:"photosUploaded")
        photoObject.addUniqueObject(thumbnailFile, forKey: "photosLiked")
        
        var queryEvent = PFQuery(className: "Event")
        queryEvent.whereKey("objectId", equalTo: self.eventId!)
        var objects = queryEvent.findObjects() as! [PFObject]
        var eventObject = objects[0]
        
        let relation = eventObject.relationForKey("photos")
        
        photo.save()
        
        relation.addObject(photo)
        photoObject.addUniqueObject(photo.objectId!, forKey: "photosUploadedID")
        photoObject.addUniqueObject(photo.objectId!, forKey: "photosLikedID")
        
        eventObject.saveInBackground()
        
        photoObject.saveInBackground()
        
    }
    
    func compressImage(image:UIImage, shrinkRatio: CGFloat) -> NSData {
        var imageHeight:CGFloat = image.size.height
        var imageWidth:CGFloat = image.size.width
        var maxHeight:CGFloat = 1136.0 * shrinkRatio
        var maxWidth:CGFloat = 640.0 * shrinkRatio
        var imageRatio:CGFloat = imageWidth/imageHeight
        var scalingRatio:CGFloat = maxWidth/maxHeight
        
        //lowest quality rating with acceptable encoding
        var quality:CGFloat = 0.5
        
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
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: cancelCompletionHandler)
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
