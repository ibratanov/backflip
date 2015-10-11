//
//  BFCameraController.swift
//  PreviewStandalone
//
//  Created by Jack Perry on 2015-10-06.
//  Copyright © 2015 Backflip Inc. All rights reserved.
//

import UIKit
import Foundation

import Photos
import QBImagePicker


/**
 * Settings
*/

public let kMULTI_UPLOAD_ASSET_LIMIT : UInt = 10



public class BFCameraController : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BFImagePreviewDelegate, QBImagePickerControllerDelegate
{

	/**
	 * Singleton
	*/
	public static let sharedController = BFCameraController.init()


	/**
	 * Event we're uploading too
	*/
	weak var event : Event?


	internal var _imagePickerController = UIImagePickerController()

	internal let transitionDelegate = BFImagePreviewTransitionDelegate()


	//------------------------------
	// MARK: Initializers
	//------------------------------
	
	override private init()
	{
		super.init()

		_imagePickerController.delegate = self

		if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
			_imagePickerController.sourceType = .Camera
			_imagePickerController.allowsEditing = false
			_imagePickerController.showsCameraControls = false

			let cameraOverlayView = BFCameraOverlay.init(frame: CGRectZero)
			cameraOverlayView.imagePicker = _imagePickerController

			_imagePickerController.cameraOverlayView = cameraOverlayView
		}

	}


	//----------------------------------------
	// MARK: Image Picker Sheet
	//----------------------------------------

	public func presentImagePickerSheet()
	{

		let window = UIApplication.sharedApplication().windows.first
		let viewController : UIViewController = (window?.rootViewController)!
		let imagePickerSheet = ImagePickerSheetController(mediaType: .Image)

		imagePickerSheet.maximumSelection = NSNumber(unsignedLong: kMULTI_UPLOAD_ASSET_LIMIT).integerValue

		// Take Photo
		imagePickerSheet.addAction(ImagePickerAction(title: "Take Photo", style: .Default, handler: { (action) -> () in
			self.presentCamera()
		}, secondaryHandler: nil))


		// Photo Library
		imagePickerSheet.addAction(ImagePickerAction(title: "Photo Library", secondaryTitle: {"Upload \($0) Photo(s)" as String}, style: .Default, handler: { (action) -> () in
			self.presentPhotoLibrary()
		}, secondaryHandler: { (action, index) -> () in

			autoreleasepool({ () -> () in

				let assets = imagePickerSheet.selectedImageAssets
				if (assets.count > 0) {
					let options = PHImageRequestOptions()
					options.deliveryMode = .FastFormat
					options.resizeMode = .None
					options.synchronous = false

					for asset in assets {
						PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(2048, 2048), contentMode: .Default, options: options, resultHandler: { (image, object) -> Void in
							self.uploadImage(image, comment: nil)
						}) 
					}
				}
				
			})

		}))


		// Cancel button
		imagePickerSheet.addAction(ImagePickerAction(title: "Cancel", style: .Cancel, handler: { _ in
			print("Image Picker Sheet canceled")
		}))


		// Image Picker sheet presentation
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			imagePickerSheet.modalPresentationStyle = .Popover
			imagePickerSheet.popoverPresentationController?.sourceView = viewController.view
			imagePickerSheet.popoverPresentationController?.sourceRect = CGRect(origin: viewController.view.center, size: CGSize())
		}

		viewController.presentViewController(imagePickerSheet, animated: true, completion: nil)
	}
	


	//----------------------------------------
	// MARK: Display Camera
	//----------------------------------------

	public func presentCamera()
	{
		let window = UIApplication.sharedApplication().windows.first
		let viewController : UIViewController = (window?.rootViewController)!

		if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
			_imagePickerController.sourceType = .Camera
			_imagePickerController.cameraOverlayView?.frame = viewController.view.bounds

			if (event != nil) {
				(_imagePickerController.cameraOverlayView as? BFCameraOverlay)!.eventLabel?.text = event!.name
			}
		} else {
			print("📷 Unable to present camera due to lack of support for it, Simulator anyone?")
			return 
		}

		viewController.presentViewController(_imagePickerController, animated: true, completion: nil)
	}
	

	//----------------------------------------
	// MARK: Photo Library
	//----------------------------------------

	public func presentPhotoLibrary()
	{
		let window = UIApplication.sharedApplication().windows.first
		let viewController : UIViewController = (window?.rootViewController)!

		let multiImagePicker = QBImagePickerController()
		multiImagePicker.delegate = self
		multiImagePicker.mediaType = .Image
		multiImagePicker.allowsMultipleSelection = true
		multiImagePicker.maximumNumberOfSelection = kMULTI_UPLOAD_ASSET_LIMIT
		multiImagePicker.showsNumberOfSelectedAssets = true

		viewController.presentViewController(multiImagePicker, animated: true, completion: nil)
	}


	//----------------------------------------
	// MARK: Image Preview Controller
	//----------------------------------------
	
	public func presentPreviewController(image: UIImage?)
	{
		let window = UIApplication.sharedApplication().windows.first
		let viewController : UIViewController = (window?.rootViewController)!
		let controller = BFImagePreviewController(nibName: nil, bundle: nil)
		controller.transitioningDelegate = transitionDelegate
		controller.modalPresentationStyle = .Custom
		controller.delegate = self
		controller.image = image
		
		viewController.presentViewController(controller, animated: true, completion: nil)
	}



	//----------------------------------------
	// MARK: Multi-Image Picker Delegate
	//----------------------------------------

	public func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController)
	{
		imagePickerController.dismissViewControllerAnimated(true, completion: nil)
	}

	
	public func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!)
	{
		imagePickerController.dismissViewControllerAnimated(true, completion: nil)

		autoreleasepool({ () -> () in

			if (assets.count > 0) {
				let options = PHImageRequestOptions()
				options.deliveryMode = .FastFormat
				options.resizeMode = .None
				options.synchronous = false

				for asset in (assets as! [PHAsset]) {
					PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(2048, 2048), contentMode: .Default, options: options, resultHandler: { (image, object) -> Void in
						self.uploadImage(image, comment: nil)
					})
				}
			}

		})
	}



	//----------------------------------------
	// MARK: Image Preview Delegate
	//----------------------------------------

	public func imagePreviewDidCancel(imagePreview: BFImagePreviewController)
	{
		print("Did dismiss after previewing image..")
	}

	public func imagePreviewDidSelectUploadButton(imagePreview: BFImagePreviewController, button: UIButton?, image: UIImage?, comment: String?)
	{
		self.uploadImage(image, comment: comment)
	}



	//----------------------------------------
	// MARK: Image Picker Delegate
	//----------------------------------------

	public func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
	{
		picker.dismissViewControllerAnimated(true) { () -> Void in
			self.presentPreviewController(image)
		}
	}



	//----------------------------------------
	// MARK: Image Uploading
	//----------------------------------------

	private func uploadImage(image: UIImage?, comment: String?)
	{
		print("🎥 Upload image to Parse now..")
	}

}