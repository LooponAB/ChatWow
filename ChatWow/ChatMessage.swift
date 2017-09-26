//
//  ChatMessage.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

public protocol ChatMessage
{
	var side: InterlocutorSide { get }
	var date: Date { get }
}

extension ChatMessage
{
	public var viewIdentifier: String
	{
		return side == .mine ? "chat_default_mine" : "chat_default_theirs"
	}
}

public enum InterlocutorSide
{
	case mine
	case theirs
}

public class ChatTextMessage: ChatMessage
{
	public var text: String
	public var side: InterlocutorSide
	public var date: Date

	init(text: String, side: InterlocutorSide, date: Date)
	{
		self.text = text
		self.side = side
		self.date = date
	}
}
