//
//  BFPreviewDescriptionCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-18.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class BFPreviewDescriptionCell : BFPreviewCell
{
	
	/**
	 * Markdown Label
	*/
	internal var markdownLabel: UILabel!
	
	
	/**
	 * (reuse) Identifier
	*/
	static let identifier: String = "preview-description-cell"
	
	
	
	
	
	// ----------------------------------------
	//  MARK: - Initializers
	// ----------------------------------------
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.loadView()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		self.loadView()
	}
	
	
	/**
	* View creation
	*/
	private func loadView() -> Void
	{
		self.markdownLabel = UILabel(frame: CGRectZero)
		self.markdownLabel.lineBreakMode = .ByWordWrapping
		self.markdownLabel.numberOfLines = 0
		if #available(iOS 8.2, *) {
		    self.markdownLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightLight)
		} else {
		    self.markdownLabel.font = UIFont.systemFontOfSize(17.0)
		}
		self.markdownLabel.userInteractionEnabled = true
		self.contentView.addSubview(self.markdownLabel)
	}
	
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		self.markdownLabel.frame = CGRectMake(5, 7.55, self.frame.width - 10, self.cellHeight() + 5.0)
	}
	
	
	
	/**
	 * Cell Height
	*/
	override func cellHeight() -> CGFloat
	{
		let frame = UIApplication.sharedApplication().windows.first!.rootViewController!.view.frame
		let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading, .TruncatesLastVisibleLine]
		let attributedSize = self.markdownLabel.attributedText?.boundingRectWithSize(CGSizeMake((frame.width - 10), 10000), options:options, context: nil)
		return attributedSize!.height - 5.0
	}
	
	
	override func configureCell(withEvent event: Event?)
	{
		let exampleText = (event?.eventDescription != nil) ? event!.eventDescription! : ""
		
		var markdown = Markdown()
		var htmlContent: String = markdown.transform(exampleText)
		htmlContent = "<style>body{font-family: '\(self.markdownLabel.font.fontName)'; font-size:\(17.0)px;}</style> \(htmlContent)"
		
		
		var font: UIFont!
		if #available(iOS 8.2, *) {
			font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightLight)
		} else {
			font = UIFont.systemFontOfSize(17.0)
		}
		
		let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: font]
		let attributedString = try! NSAttributedString(data: htmlContent.dataUsingEncoding(NSUTF8StringEncoding)!, options: attributedOptions, documentAttributes: nil)
		
		self.markdownLabel.attributedText = attributedString
	}
	
}
