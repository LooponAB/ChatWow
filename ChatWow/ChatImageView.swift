//
//  ChatImageView.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 27/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

@IBDesignable
open class ChatImageView: UIImageView
{
	lazy var maximumSize: CGSize =
	{
		return bounds.size
	}()

	override init(frame: CGRect)
	{
		super.init(frame: frame)

		setupMaskBubble()
	}

	override init(image: UIImage?)
	{
		super.init(image: image)

		setupMaskBubble()
	}

	override init(image: UIImage?, highlightedImage: UIImage?)
	{
		super.init(image: image, highlightedImage: highlightedImage)

		setupMaskBubble()
	}

	required public init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)

		setupMaskBubble()
	}

	private func setupMaskBubble()
	{
		mask = ChatBubbleView(frame: bounds)
		mask?.backgroundColor = .clear
		mask?.setNeedsDisplay()
	}

	override open var bounds: CGRect
	{
		didSet
		{
			mask?.frame = bounds
			mask?.setNeedsDisplay()
			setNeedsDisplay()
		}
	}

	@IBInspectable
	var legOnLeft: Bool
	{
		get
		{
			return (mask as? ChatBubbleView)?.legOnLeft ?? false
		}

		set
		{
			(mask as? ChatBubbleView)?.legOnLeft = newValue
		}
	}

	override open var intrinsicContentSize: CGSize
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
