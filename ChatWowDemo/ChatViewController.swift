//
//  ChatViewController.swift
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
			"Let's travel! 🗽🗺",
			"A slightly longer message so we see it wrap",
			"A string that has emojis in it 🤔",
			"👽❕",
			"🛩",
			#imageLiteral(resourceName: "image_1"),
			#imageLiteral(resourceName: "image_2"),
			"🚢",
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

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.setNeedsUpdateReadInfo() }
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
		// Just for demo purposes, use the timestamp of some older message, and skip the 2 most recent mssages.
		return index < 2 ? nil : chats[4].date
	}

	func numberOfPendingMessages(in chatController: ChatWowViewController) -> Int
	{
		return 0
	}

	func chatController(_ chatController: ChatWowViewController, pendingChatMessageWith index: Int) -> ChatMessage
	{
		return ChatTextMessage(text: "Demo", side: .mine, date: Date())
	}
}

extension ChatViewController: ChatWowDelegate
{
	func chatController(_ chatController: ChatWowViewController, didInsertMessage message: String)
	{
		guard message != "" else { return }

		chats.insert(ChatTextMessage(text: message, side: .mine, date: Date()), at: 0)
		insert(newMessages: 1, scrollToBottom: true)
		clearInput()
	}

	func chatController(_ chatController: ChatWowViewController, prepare cellView: ChatMessageView, for message: ChatMessage)
	{
		// If any custom chat views need some processing before being displayed, do it here.
	}

	func chatController(_ chatController: ChatWowViewController, didTapMessageWith index: Int)
	{
		// This can be used for custom behavior, like opening an imge message on full screen.
	}

	func chatController(_ chatController: ChatWowViewController, didTapPendingMessageWith index: Int)
	{
		// If a pending message failed sending, let the user tap it to try again, and process the tap event here.
	}

	func chatController(_ chatController: ChatWowViewController, estimatedHeightForMessageWith index: Int) -> CGFloat?
	{
		// If you use custom cell times, it is seriously encouraged that you estimate its height properly here.
		return nil
	}
}

