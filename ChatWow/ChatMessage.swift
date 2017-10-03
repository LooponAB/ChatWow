//
//  ChatMessage.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

public protocol ChatMessage
{
	var side: InterlocutorSide { get }
	var date: Date { get }
	var showTimestamp: Bool { get }

	var viewIdentifier: String { get }
}

public enum InterlocutorSide
{
	case mine
	case theirs
}

open class ChatTextMessage: ChatMessage
{
	public var text: String
	public var side: InterlocutorSide
	public var date: Date
	public var showTimestamp: Bool

	public init(text: String, side: InterlocutorSide, date: Date, showTimestamp: Bool = true)
	{
		self.text = text
		self.side = side
		self.date = date
		self.showTimestamp = showTimestamp
	}

	var useBigEmoji: Bool
	{
		return text.isPureEmoji
	}

	public var viewIdentifier: String
	{
		// This is bad but oh well 😔
		if useBigEmoji
		{
			return side == .mine ? "chat_default_emoji_mine" : "chat_default_emoji_theirs"
		}
		else
		{
			return side == .mine ? "chat_default_mine" : "chat_default_theirs"
		}
	}
}

open class ChatAnnotationMessage: ChatTextMessage
{
	public override var viewIdentifier: String
	{
		return "chat_default_info_with_time"
	}
}

open class ChatImageMessage: ChatMessage
{
	public var side: InterlocutorSide
	public var date: Date
	public var image: UIImage
	public var showTimestamp: Bool

	public init(image: UIImage, side: InterlocutorSide, date: Date, showTimestamp: Bool = true)
	{
		self.image = image
		self.side = side
		self.date = date
		self.showTimestamp = showTimestamp
	}

	public var viewIdentifier: String
	{
		return side == .mine ? "chat_default_image_mine" : "chat_default_image_theirs"
	}
}

internal class ChatReadAnnotationMessage: ChatAnnotationMessage
{
	override var viewIdentifier: String
	{
		return "chat_default_info"
	}

}

extension String
{
	var isPureEmoji: Bool
	{
		guard (self as NSString).responds(to: Selector(("_containsEmoji"))) else
		{
			return false
		}

		for character in self
		{
			let charString = String(character) as NSString

			if let result = charString.value(forKey: "_containsEmoji") as? Bool, !result
			{
				return false
			}
		}

		return true
	}
}
