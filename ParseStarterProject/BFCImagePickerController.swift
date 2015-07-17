//
//  BFCImagePickerController.swift
//  Backflip
//
//  Created by MWars on 2015-07-15.
//  Copyright (c) 2015 Parse. All rights reserved.

import UIKit
import AssetsLibrary

protocol BFCImagePickerControllerDelegate : NSObjectProtocol {
    func imagePickerControllerDidSelectedAssets(images: [BFCAsset]!)
    func imagePickerControllerCancelled()
}

let GroupCellIdentifier = "GroupCellIdentifier"
let ImageCellIdentifier = "ImageCellIdentifier"
let BFCImageSelectedNotification = "BFCImageSelectedNotification"
let BFCImageUnselectedNotification = "BFCImageUnselectedNotification"

class BFCAssetGroup : NSObject {
    var groupName: String!
    var thumbnail: UIImage!
    var group: ALAssetsGroup!
}

class BFCAsset: NSObject {
    var thumbnailImage: UIImage?
    lazy var fullScreenImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        }()
    lazy var fullResolutionImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
        }()
    var url: NSURL?
    
    private var originalAsset: ALAsset!
    
    override func isEqual(object: AnyObject?) -> Bool {
        let other = object as! BFCAsset!
        return self.url!.isEqual(other.url!)
    }
}

extension UIViewController {
    var imagePickerController: BFCImagePickerController? {
        get {
            let nav = self.navigationController
            if nav is BFCImagePickerController {
                return nav as? BFCImagePickerController
            } else {
                return nil
            }
        }
    }
}

// Collection view of grouped assets//////////////////////////////////////////////////

class BFCAssetsLibraryController: UICollectionViewController {
    
    lazy private var groups: NSMutableArray = {
        return NSMutableArray()
        }()
    
    lazy private var library: ALAssetsLibrary = {
        return ALAssetsLibrary()
        }()
    
    private var noAccessView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {(group: ALAssetsGroup! , stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                if group.numberOfAssets() != 0 {
                    //open photo lib
                    
                    let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
                    
                    let assetGroup = BFCAssetGroup()
                    assetGroup.groupName = groupName
                    assetGroup.thumbnail = UIImage(CGImage: group.posterImage().takeUnretainedValue())
                    assetGroup.group = group
                    self.groups.insertObject(assetGroup, atIndex: 0)
                    
                    let assetGroup2 = self.groups[0] as! BFCAssetGroup
                    
                    //                    let imageGroupController = BFCImageGroupViewController()
                    //                    imageGroupController.assetGroup = assetGroup2
                    self.assetGroup = assetGroup2
                    //                    self.navigationController?.pushViewController(imageGroupController, animated: true)
                    
                    assert(self.assetGroup != nil, "Error")
                    
                    self.title = assetGroup.groupName
                    
                    self.collectionView!.backgroundColor = UIColor.whiteColor()
                    self.collectionView!.allowsMultipleSelection = true
                    self.collectionView!.registerClass(BFCImageCollectionCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
                    
                    assetGroup.group.enumerateAssetsUsingBlock {[unowned self](result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                        if result != nil {
                            let asset = BFCAsset()
                            asset.thumbnailImage = UIImage(CGImage:result.thumbnail().takeUnretainedValue())
                            asset.url = result.valueForProperty(ALAssetPropertyAssetURL) as? NSURL
                            asset.originalAsset = result
                            self.imageAssets.addObject(asset)
                        } else {
                            self.collectionView!.reloadData()
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forRow: self.imageAssets.count-1, inSection: 0),
                                    atScrollPosition: UICollectionViewScrollPosition.Bottom,
                                    animated: false)
                            }
                        }
                    }
                }
            }
            }, failureBlock: {(error: NSError!) in
                self.noAccessView.frame = self.view.bounds
                self.view.addSubview(self.noAccessView)
        })
        
    }
    
    class BFCImageCollectionCell: UICollectionViewCell {
        var thumbnail: UIImage! {
            didSet {
                self.imageView.image = thumbnail
            }
        }
        
        override var selected: Bool {
            didSet {
                checkView.hidden = !super.selected
            }
        }
        
        private var imageView = UIImageView()
        private var checkView = UIImageView(image: UIImage(named: "photo_checked"))
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView.frame = self.bounds
            self.contentView.addSubview(imageView)
            self.contentView.addSubview(checkView)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageView.frame = self.bounds
            checkView.frame.origin = CGPoint(x: self.contentView.bounds.width - checkView.bounds.width,
                y: self.contentView.bounds.height - checkView.bounds.height)
        }
    }
    
    var assetGroup: BFCAssetGroup!
    private lazy var imageAssets: NSMutableArray = {
        return NSMutableArray()
        }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        
        let interval: CGFloat = 3
        layout.minimumInteritemSpacing = interval
        layout.minimumLineSpacing = interval
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let itemWidth = (screenWidth - interval * 3) / 4
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        self.init(collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Error must init!")
    }
        
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! BFCImageCollectionCell
        
        let asset = imageAssets[indexPath.row] as! BFCAsset
        cell.thumbnail = asset.thumbnailImage
        
        if find(self.imagePickerController!.selectedAssets, asset) != nil {
            cell.selected = true
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        } else {
            cell.selected = false
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(BFCImageSelectedNotification, object: imageAssets[indexPath.row])
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(BFCImageUnselectedNotification, object: imageAssets[indexPath.row])
    }
}

//Main---------------------------------------------------------------

class BFCImagePickerController: UINavigationController {
    
    /// The height of the bottom of the preview
    var previewHeight: CGFloat = 80
    var rightButtonTitle: String = "Upload"
    /// Displayed when denied access
    var noAccessView: UIView = {
        let label = UILabel()
        label.text = "ACCESS DENIED!!!"
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.lightGrayColor()
        return label
        }()
    
    class BFCPreviewView: UIScrollView {
        let interval: CGFloat = 5
        private var imageLengthOfSide: CGFloat!
        private var assets = [BFCAsset]()
        private var imagesDict: [BFCAsset : UIImageView] = [:]
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageLengthOfSide = self.bounds.height - interval * 2
        }
        
        func imageFrameForIndex(index: Int) -> CGRect {
            return CGRect(x: CGFloat(index) * imageLengthOfSide + CGFloat(index + 1) * interval,
                y: (self.bounds.height - imageLengthOfSide)/2,
                width: imageLengthOfSide, height: imageLengthOfSide)
        }
        
        func insertAsset(asset: BFCAsset) {
            let imageView = UIImageView(image: asset.thumbnailImage)
            imageView.frame = imageFrameForIndex(assets.count)
            
            self.addSubview(imageView)
            assets.append(asset)
            imagesDict.updateValue(imageView, forKey: asset)
            setupContent(true)
        }
        
        func removeAsset(asset: BFCAsset) {
            imagesDict.removeValueForKey(asset)
            let index = find(assets, asset)
            if let toRemIndex = index {
                assets.removeAtIndex(toRemIndex)
                setupContent(false)
            }
        }
        
        private func setupContent(isInsert: Bool) {
            if isInsert == false {
                for (index,asset) in enumerate(assets) {
                    let imageView = imagesDict[asset]!
                    imageView.frame = imageFrameForIndex(index)
                }
            }
            self.contentSize = CGSize(width: CGRectGetMaxX((self.subviews.last as! UIView).frame) + interval,
                height: self.bounds.height)
        }
    }
    
    class BFCContentWrapperViewController: UIViewController {
        var contentViewController: UIViewController
        var bottomBarHeight: CGFloat = 0
        var showBottomBar: Bool = false {
            didSet {
                if self.showBottomBar {
                    self.contentViewController.view.frame.size.height = self.view.bounds.size.height - self.bottomBarHeight
                } else {
                    self.contentViewController.view.frame.size.height = self.view.bounds.size.height
                }
            }
        }
        
        init(_ viewController: UIViewController) {
            contentViewController = viewController
            
            super.init(nibName: nil, bundle: nil)
            self.addChildViewController(viewController)
            
            contentViewController.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.New, context: nil)
        }
        
        deinit {
            contentViewController.removeObserver(self, forKeyPath: "title")
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            if keyPath == "title" {
                self.title = contentViewController.title
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()            
            self.view.addSubview(contentViewController.view)
            contentViewController.view.frame = view.bounds
        }
    }
    
    internal var selectedAssets: [BFCAsset]!
    internal  weak var pickerDelegate: BFCImagePickerControllerDelegate?
    lazy internal var doneButton: UIButton =  {
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.setTitle("", forState: UIControlState.Normal)
        button.setTitleColor(self.navigationBar.tintColor, forState: UIControlState.Normal)
        button.reversesTitleShadowWhenHighlighted = true
        button.addTarget(self, action: "onDoneClicked", forControlEvents: UIControlEvents.TouchUpInside)
        return button
        }()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        var libraryController = BFCAssetsLibraryController()
        var wrapperVC = BFCContentWrapperViewController(libraryController)
        self.init(rootViewController: wrapperVC)
        selectedAssets = [BFCAsset]()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedImage:",
            name: BFCImageSelectedNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unselectedImage:",
            name: BFCImageUnselectedNotification,
            object: nil)
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        var wrapperVC = BFCContentWrapperViewController(viewController)
        super.pushViewController(wrapperVC, animated: animated)
        
        self.topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
        
        if self.viewControllers.count == 1 && self.topViewController?.navigationItem.leftBarButtonItem == nil {
            self.topViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                target: self,
                action: "onCancelClicked")
        }
    }
    
    func onCancelClicked() {
        if let delegate = self.pickerDelegate {
            delegate.imagePickerControllerCancelled()
        }
    }
    
    func onDoneClicked() {
        if let delegate = self.pickerDelegate {
            delegate.imagePickerControllerDidSelectedAssets(self.selectedAssets)
        }
    }
    
    func selectedImage(notification: NSNotification) {
        //set affordance for image selected
        if let asset = notification.object as? BFCAsset {
            selectedAssets.append(asset)
            self.doneButton.setTitle(rightButtonTitle + "(\(selectedAssets.count))", forState: UIControlState.Normal)
            self.doneButton.sizeToFit()
        }
    }
    
    func unselectedImage(notification: NSNotification) {
        //set affordance for image unselected
        
        if let asset = notification.object as? BFCAsset {
            selectedAssets.removeAtIndex(find(selectedAssets, asset)!)
            self.doneButton.setTitle(rightButtonTitle + "(\(selectedAssets.count))", forState: UIControlState.Normal)
            self.doneButton.sizeToFit()
            
            if selectedAssets.count <= 0 {

                self.doneButton.setTitle("", forState: UIControlState.Normal)
            }
        }
    }
}
