//
//  PreviewViewController.swift
//  Backflip
//
//  Created by MWars on 2015-06-15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var referenceView: UIView!
    @IBOutlet weak var topBlockerScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSuperviewScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBlockerScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftSuperviewScrollViewConstraint: NSLayoutConstraint!
    
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
    
    enum ADLayoutPriority: UILayoutPriority {
        case Required  = 1000
        case DefaultHigh  = 750
        case DefaultLow  = 250
        case FittingSizeLevel  = 50
    }
    
    private let NibName = "PreviewViewController"
    
    required init(coder aDecoder: NSCoder) {
        super.init(nibName: NibName, bundle: nil);
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert({ self.imageToCrop != nil }(), "image not set before PreviewViewController's view is loaded.")
        
        imageView.image = imageToCrop!
    }
    
    override func updateViewConstraints() {
        imageView.sizeToFit()
        if imageView.bounds.size.aspect() >= 1 {
            leftSuperviewScrollViewConstraint.priority = ADLayoutPriority.DefaultHigh.rawValue
            topSuperviewScrollViewConstraint.priority = ADLayoutPriority.DefaultLow.rawValue
        }
        else {
            leftSuperviewScrollViewConstraint.priority = ADLayoutPriority.DefaultLow.rawValue
            topSuperviewScrollViewConstraint.priority = ADLayoutPriority.DefaultHigh.rawValue
        }
        if imageView.bounds.size.aspect() >= 1 {
            topBlockerScrollViewConstraint.priority = ADLayoutPriority.DefaultHigh.rawValue
            leftBlockerScrollViewConstraint.priority = ADLayoutPriority.DefaultLow.rawValue
        }
        else {
            topBlockerScrollViewConstraint.priority = ADLayoutPriority.DefaultLow.rawValue
            leftBlockerScrollViewConstraint.priority = ADLayoutPriority.DefaultHigh.rawValue
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        
        let cropDimension = cropOpeningView.bounds.size.minDimension()
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.15
        
        //scrollView.zoomScale = scrollView.minimumZoomScale
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
        UIImageWriteToSavedPhotosAlbum(self.imageView.image?.croppedToRect(imageViewRect), nil, nil, nil)
        
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: cancelCompletionHandler)
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
