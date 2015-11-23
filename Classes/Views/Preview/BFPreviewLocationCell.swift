//
//  BFPreviewLocationCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-17.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation

public class BFPreviewLocationCell : BFPreviewCell, MKMapViewDelegate
{
	
	public static let identifier: String = "preview-location-cell"
	
	/**
	 * Map View
	*/
	public var mapView: MKMapView!
	
	/**
	 * Header title
	*/
	private var titleView: BFPreviewTitleView!
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.loadView()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		self.loadView()
	}
	
	
	/**
	 * View creation
	*/
	private func loadView() -> Void
	{
		self.mapView = MKMapView(frame: CGRectZero)
		self.mapView.delegate = self
		self.mapView.layer.borderColor = UIColor.lightGrayColor().CGColor
		self.mapView.layer.borderWidth = 0.5
		self.mapView.layer.cornerRadius = 8.0
		self.mapView.showsUserLocation = true
		self.mapView.userInteractionEnabled = false
		self.contentView.addSubview(self.mapView)
		
		self.titleView = BFPreviewTitleView(frame: CGRectZero)
		self.titleView.text = "Location"
		self.contentView.addSubview(self.titleView)
	}
	
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.titleView.frame = CGRectMake(0, 0, self.frame.width, 20)
		self.mapView.frame = CGRectMake(5, 25, self.frame.width - 10, 150)
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Configuration
	// ----------------------------------------
	
	
	public override func prepareForReuse() -> Void
	{
		super.prepareForReuse()
		self.mapView.removeAnnotations(self.mapView.annotations)
	}
	
	public override func cellHeight() -> CGFloat
	{
		return 180.0
	}
	
	public override func configureCell(withEvent event: Event?) -> Void
	{
		let locationPin = MKPointAnnotation()
		locationPin.coordinate = CLLocationCoordinate2DMake(Double(event!.geoLocation!.latitude!), Double(event!.geoLocation!.longitude!))
		locationPin.title = event!.name
		locationPin.subtitle = event!.venue
		self.mapView.addAnnotation(locationPin)
		
		
		let mapRegion = MKCoordinateRegionMake(locationPin.coordinate, MKCoordinateSpanMake(0.02, 0.02))
		self.mapView.setRegion(mapRegion, animated: true)
		
		if (event!.regionRadius != nil) {
			let locationRadius = MKCircle(centerCoordinate: locationPin.coordinate, radius: event!.regionRadius!.doubleValue)
			self.mapView.addOverlay(locationRadius)
		}
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Map view Delegate
	// ----------------------------------------

	@available(iOS 7.0, *)
	public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
	{
		// Location Radius
		if let overlay = overlay as? MKCircle {
			let circleRenderer = MKCircleRenderer(circle: overlay)
			circleRenderer.fillColor = UIColor.redColor().colorWithAlphaComponent(0.2)
			circleRenderer.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.3)
			circleRenderer.lineWidth = 1.0
			return circleRenderer
		}
		
		return MKOverlayRenderer()
	}

}
