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
	
	internal var controllerCache = NSCache()
	
	internal var pageControl : UIPageControl?
	
	
	// --------------------------------------
	//  MARK: View Management
	// --------------------------------------
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		dataSource = self
		
		self.pageControl = UIPageControl(frame: CGRectMake(10, 10, 100, 20))
		self.pageControl?.numberOfPages = 10
		self.view.bringSubviewToFront(self.pageControl!)
	}
	
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.dataSource = self
		let initialViewController = viewControllerForPage(0)
		self.setViewControllers([initialViewController], direction: .Forward, animated: false, completion: nil)
		
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