//
//  ChatImageView.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 27/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

class ChatImageView: UIImageView
{
	var maximumSize: CGSize = CGSize.zero

	override var intrinsicContentSize: CGSize
	{
		return image?.size.aspectRect(maximumSize: maximumSize) ?? maximumSize
	}
}

extension CGSize
{
	func aspectRect(maximumSize: CGSize) -> CGSize
	{
		if width > height
		{
			return CGSize(width: maximumSize.width, height: height * (maximumSize.width / width))
		}
		else
		{
			return CGSize(width: width * (maximumSize.height / height), height: maximumSize.height)
		}
	}
}
