//
//  ChatMessage.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB
//  Contact us at support@loopon.com
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
//  following conditions are met:
//  
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
//  disclaimer.
//  
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
//  following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
//  products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

public protocol ChatMessage
{
	var side: InterlocutorSide { get }
	var date: Date { get }
	var showTimestamp: Bool { get }
	var hasError: Bool { get }

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
	public var hasError: Bool = false

	public init(text: String, side: InterlocutorSide, date: Date, showTimestamp: Bool = true, hasError: Bool = false)
	{
		self.text = text
		self.side = side
		self.date = date
		self.showTimestamp = showTimestamp
		self.hasError = hasError
	}

	var useBigEmoji: Bool
	{
		return text.isPureEmoji
	}

	open var viewIdentifier: String
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
	open override var viewIdentifier: String
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
	public var hasError: Bool = false

	public init(image: UIImage, side: InterlocutorSide, date: Date, showTimestamp: Bool = true)
	{
		self.image = image
		self.side = side
		self.date = date
		self.showTimestamp = showTimestamp
	}

	open var viewIdentifier: String
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
