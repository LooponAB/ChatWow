//
//  ChatMessageView.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

/// The view used for each individual chat message.
public class ChatMessageView: UITableViewCell
{
	static let kErrorImageViewWidth: CGFloat = 32

	@IBOutlet open var chatLabel: UILabel?
	@IBOutlet open var timeLabel: UILabel?
	@IBOutlet open var chatImageView: ChatImageView?
	@IBOutlet open var errorImageView: UIImageView?
	@IBOutlet open var errorImageConstraint: NSLayoutConstraint?

	// A view that can be made transluscent (it can be a view already attached to another IBOutlet)
	@IBOutlet open var transluscentView: UIView?

	var hasError: Bool = false
	{
		didSet
		{
			errorImageConstraint?.constant = hasError ? ChatMessageView.kErrorImageViewWidth : 0.0
		}
	}

	public override var frame: CGRect
	{
		didSet
		{
			subviews.forEach({ $0.setNeedsDisplay() })
			setNeedsDisplay()
		}
	}
}
