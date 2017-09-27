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
	@IBOutlet var chatLabel: UILabel?
	@IBOutlet var timeLabel: UILabel?
	@IBOutlet var chatImageView: UIImageView?
	{
		didSet
		{
			chatImageView?.layer.cornerRadius = 11.0
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
