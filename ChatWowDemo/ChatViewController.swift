//
//  ChatViewController.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit
import ChatWow

class ChatViewController: ChatWowViewController
{
	var chats = [ChatMessage]()

	override func viewDidLoad()
	{
		dataSource = self
		delegate = self

		for i in 0..<6
		{
			let date = Date(timeIntervalSinceNow: 60 * TimeInterval(arc4random() % 360) * -1)
			chats.append(ChatTextMessage(text: "Lorem ipsum dolor sit amet! Lorem ipsum dolor sit amet! Lorem ipsum dolor sit amet!  \(i)", side: (i % 2 == 0) ? .mine : .theirs, date: date))
		}

		chats.sort { (msg1, msg2) -> Bool in
			return msg1.date > msg2.date
		}

		chats.insert(ChatAnnotationMessage(text: "John Appleseed has gone offline", side: .theirs, date: Date()), at: 0)

		bubbleColorMine = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)

		super.viewDidLoad()
	}

	@IBAction func addMessages(_ sender: Any)
	{
		var newMessages: [Any] = [
			"A new message",
			"Another new message",
			"A message",
			"Oh hai",
			"A slightly longer message so we see it wrap",
			"A string that has emojis in it 🤔🤡",
			"👽❕",
			"💩",
			UIImage(named: "image_1")!,
			UIImage(named: "image_2")!
		]

		let newMessage = newMessages[Int(arc4random()) % newMessages.count]

		if let newTextMessage = newMessage as? String
		{
			chats.insert(ChatTextMessage(text: newTextMessage, side: (arc4random() % 2) == 0 ? .mine : .theirs, date: Date()), at: 0)
		}
		else if let newImageMessage = newMessage as? UIImage
		{
			chats.insert(ChatImageMessage(image: newImageMessage, side: (arc4random() % 2) == 0 ? .mine : .theirs, date: Date()), at: 0)
		}
		else
		{
			return
		}

		insert(newMessages: 1, scrollToBottom: true)

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
			{
				self.updateReadInfo()
			}
	}
}

extension ChatViewController: ChatWowDataSource
{
	func numberOfMessages(in chatController: ChatWowViewController) -> Int
	{
		return chats.count
	}

	func chatController(_ chatController: ChatWowViewController, chatMessageWith index: Int) -> ChatMessage
	{
		return chats[index]
	}

	func chatController(_ chatController: ChatWowViewController, readDateForMessageWith index: Int) -> Date?
	{
		return index < 2 ? nil : chats[4].date
	}
}

extension ChatViewController: ChatWowDelegate
{
	func chatController(_ chatController: ChatWowViewController, userDidInsertMessage message: String)
	{
		guard message != "" else { return }

		chats.insert(ChatTextMessage(text: message, side: .mine, date: Date()), at: 0)
		insert(newMessages: 1, scrollToBottom: true)
		clearInput()
	}

	func chatController(_ chatController: ChatWowViewController, prepareChatView cellView: ChatMessageView)
	{

	}
}

