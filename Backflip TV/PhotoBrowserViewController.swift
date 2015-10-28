//
//  PhotoBrowserViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


class PhotoBrowserViewController : UIPageViewController, UIPageViewControllerDataSource
{
	
	var photos : [PFObject] = []
	
	var initialPageIndex = 0
	
	internal var controllerCache = NSCache()


	/**
	 * Slideshow
	*/
	internal var slideshowMode : Bool = false

	internal let slideshowDuration : Double = 3

	
	// --------------------------------------
	//  MARK: View Management
	// --------------------------------------
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		dataSource = self

		let tapRecognizer = UITapGestureRecognizer(target: self, action: "handlePlayPausePress:")
		tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
		self.view.addGestureRecognizer(tapRecognizer)
	}
	
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		dataSource = self
		let initialViewController = viewControllerForPage(initialPageIndex)
		self.setViewControllers([initialViewController], direction: .Forward, animated: false, completion: nil)
		
	}
	
	

	// --------------------------------------
	//  MARK: Slideshow
	// --------------------------------------

	func handlePlayPausePress(sender: AnyObject?)
	{
		slideshowMode = !slideshowMode

		if (slideshowMode == true) {
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(slideshowDuration * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				self.updateSlideshow()
			}
		}
	}

	func updateSlideshow()
	{
		if (slideshowMode == true) {
			let index = 1 + indexOfPhotoForViewController(self.viewControllers!.first!)
			if (index > 0 && index < self.photos.count) {
				let viewController = self.viewControllerForPage(index)
				self.setViewControllers([viewController], direction: .Forward, animated: true, completion: nil)
			} else if (index == self.photos.count) {
				let viewController = self.viewControllerForPage(0)
				self.setViewControllers([viewController], direction: .Forward, animated: true, completion: nil)
			}


			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(slideshowDuration * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				self.updateSlideshow()
			}
		}
 	}


	// --------------------------------------
	//  MARK: Page View Controller
	// --------------------------------------
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
	{
		let index = indexOfPhotoForViewController(viewController)
		
		if index > 0 {
			return viewControllerForPage(index - 1)
		} else {
			return nil
		}
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
	{
		let index = indexOfPhotoForViewController(viewController)
		
		if index < photos.count - 1 {
			return viewControllerForPage(index + 1)
		} else {
			return nil
		}
	}
	
	func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
	{
		return self.photos.count
	}
	
	func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
	{
		guard let currentViewController = pageViewController.viewControllers?.first else { fatalError("Unable to get the page controller's current view controller.") }
		
		return indexOfPhotoForViewController(currentViewController)
	}
	
	
	
	// --------------------------------------
	//  MARK: View Controller Cache
	// --------------------------------------
	
	internal func indexOfPhotoForViewController(viewController: UIViewController) -> Int
	{
		guard let viewController = viewController as? PhotoBrowserItemViewController else { fatalError("Unexpected view controller type in page view controller.") }
		guard let viewControllerIndex = photos.indexOf(viewController.photo!) else { fatalError("View controller's data item not found.") }
		
		return viewControllerIndex
	}
	
	internal func viewControllerForPage(pageIndex: Int) -> UIViewController
	{
		let photo = photos[pageIndex]
		if  let cachedController = controllerCache.objectForKey(photo.objectId!) as? PhotoBrowserItemViewController {
			return cachedController
		}
	
		let controller = PhotoBrowserItemViewController()
		controller.photo = photo
		
		let image = photo["image"] as? PFFile
		if (image != nil) {
			let imageUrl = NSURL(string: image!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
			controller.imageView.nk_setImageWithURL(imageUrl)
		}
		
		controllerCache.setObject(controller, forKey: photo.objectId!)
		return controller
	}
	
	
}