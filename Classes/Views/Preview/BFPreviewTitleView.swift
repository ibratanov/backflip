//
//  BFPreviewTitleView.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-17.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

public class BFPreviewTitleView: UIView
{
	/**
	 * Line Height & Padding
	*/
	private let LINE_HEIGHT: CGFloat = 0.5
	private let LINE_PADDING: CGFloat = 5.0
	
	
	/**
	 * Lines
	*/
	private let leftLine: UIView = UIView(frame: CGRectZero)
	private let rightLine: UIView = UIView(frame: CGRectZero)
	
	
	/**
	 * Label
	*/
	private var textLabel: UILabel!
	
	
	/**
	 * Text
	*/
	public var text: String? {
		didSet {
			self.textLabel.text = self.text
			self.setNeedsLayout()
		}
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		self.loadView()
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		self.loadView()
	}
	
	
	
	
	// ----------------------------------------
	//  MARK: - View Loading / Layout
	// ----------------------------------------
	
	private func loadView() -> Void
	{
		self.textLabel = UILabel(frame: CGRectZero)
		if #available(iOS 8.2, *) {
		    self.textLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
		} else {
		   self.textLabel.font = UIFont.systemFontOfSize(16)
		}
		self.textLabel.textColor = UIColor.lightGrayColor()
		self.leftLine.backgroundColor = UIColor.lightGrayColor()
		self.rightLine.backgroundColor = UIColor.lightGrayColor()
		
		self.addSubview(self.textLabel)
		self.addSubview(self.leftLine)
		self.addSubview(self.rightLine)
	}
	
	public override func layoutSubviews()
	{
		super.layoutSubviews()
		
		if (self.textLabel.text != nil) {
			
			let textSize = self.text!.sizeWithAttributes([NSFontAttributeName: self.textLabel.font])
			
			self.textLabel.frame = CGRectMake((self.frame.width/2)-(textSize.width/2), (self.bounds.height/2)-(textSize.height/2), textSize.width, textSize.height)
			self.leftLine.frame = CGRectMake(LINE_PADDING, (self.bounds.height/2) - (LINE_HEIGHT/2), self.textLabel.frame.origin.x-(LINE_PADDING*2), LINE_HEIGHT)
			self.rightLine.frame = CGRectMake(LINE_PADDING  + (self.textLabel.frame.origin.x + self.textLabel.frame.size.width), (self.bounds.height/2) - (LINE_HEIGHT/2), (self.frame.width - (LINE_PADDING*2)) - (self.textLabel.frame.origin.x + self.textLabel.frame.size.width), LINE_HEIGHT)
			
		}
		
	}
	
	
}
