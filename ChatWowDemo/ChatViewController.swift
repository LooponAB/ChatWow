//
//  ChatViewController.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

class ChatViewController: ChatWowViewController
{
	var chats = [ChatMessage]()

	override func viewDidLoad()
	{
		super.viewDidLoad()

		dataSource = self

		for i in 0..<32
		{
			let date = Date(timeIntervalSinceNow: 60 * TimeInterval(arc4random() % 360) * -1)
			chats.append(ChatTextMessage(text: "Lorem ipsum dolor sit amet! Lorem ipsum dolor sit amet! Lorem ipsum dolor sit amet!  \(i)", side: (i % 2 == 0) ? .mine : .theirs, date: date))
		}

		chats.sort { (msg1, msg2) -> Bool in
			return msg1.date > msg2.date
		}
	}

	@IBAction func addMessages(_ sender: Any)
	{
		var newMessages = ["A new message", "Another new message", "A message", "Oh hai."]

		chats.insert(ChatTextMessage(text: newMessages[Int(arc4random()) % newMessages.count], side: (arc4random() % 2) == 0 ? .mine : .theirs, date: Date()), at: 0)
		insertMessageCount(newMessages: 1, scrollToBottom: true)
	}
}

extension ChatViewController: ChatWowDataSource
{
	func numberOfMessages(in chatController: ChatWowViewController) -> Int
	{
		return chats.count
	}

	func chatController(_ chatController: ChatWowViewController, chatMessageWithIndex index: Int) -> ChatMessage
	{
		return chats[index]
	}
}

