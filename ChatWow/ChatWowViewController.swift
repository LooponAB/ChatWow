//
//  ChatWowViewController.swift
//  ChatDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

public protocol ChatWowDataSource
{
	/// Total number of messages available to be displayed.
	func numberOfMessages(in chatController: ChatWowViewController) -> Int

	/// The message to be displayed at a certain position from the bottom of the view. Messages should be indexed by date, with the most
	/// recent message on index `0`.
	func chatController(_ chatController: ChatWowViewController, chatMessageWithIndex index: Int) -> ChatMessage
}

public protocol ChatWowDelegate
{
	func chatController(_ chatController: ChatWowViewController, prepareChatView cellView: ChatMessageView)
}

public class ChatWowViewController: UITableViewController
{
	var dataSource: ChatWowDataSource? = nil
	var delegate: ChatWowDelegate? = nil

	private var cachedCount: Int = 0

	lazy var timeLabelDateFormatter: DateFormatter =
		{
			let formatter = DateFormatter()
			formatter.dateStyle = .none
			formatter.timeStyle = .short
			return formatter
		}()

	public override func viewDidLoad()
	{
		super.viewDidLoad()

		let bundle = Bundle(for: ChatMessageView.self)
		tableView.register(UINib(nibName: "ChatMessageMine", bundle: bundle), forCellReuseIdentifier: "chat_default_mine")
		tableView.register(UINib(nibName: "ChatMessageTheirs", bundle: bundle), forCellReuseIdentifier: "chat_default_theirs")
		tableView.register(UINib(nibName: "ChatInfoLineCell", bundle: bundle), forCellReuseIdentifier: "chat_default_info")

		setup()
	}

	private func setup()
	{
		tableView.backgroundColor = .white
		tableView.separatorStyle = .none
	}
}

extension ChatWowViewController // Chat interface
{
	func insertMessageCount(newMessages count: Int)
	{
		guard let total = dataSource?.numberOfMessages(in: self) else
		{
			return
		}

		var indexPaths = [IndexPath]()

		for i in total - count ..< total
		{
			indexPaths.append(IndexPath(row: i, section: 0))
		}

		tableView.insertRows(at: indexPaths, with: .right)
	}
}

extension ChatWowViewController
{
	/// This is where the magic of showing messages from top to bottom happens. We need to flip the default indexPath ordering (which
	/// is 0..<count) to the inverted chat message ordering (which is (count-1)...0).
	private func chatMessageIndex(for indexPath: IndexPath) -> Int
	{
		return cachedCount - indexPath.row - 1
	}

	public override func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		cachedCount = dataSource?.numberOfMessages(in: self) ?? 0
		return cachedCount
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let index = chatMessageIndex(for: indexPath)
		guard let chatMessage = dataSource?.chatController(self, chatMessageWithIndex: index) else
		{
			return UITableViewCell(style: .default, reuseIdentifier: "blank_cell")
		}

		let cell = tableView.dequeueReusableCell(withIdentifier: chatMessage.viewIdentifier, for: indexPath)
		cell.selectionStyle = .none

		if let chatView = cell as? ChatMessageView
		{
			if let textMessage = chatMessage as? ChatTextMessage
			{
				chatView.chatLabel?.text = textMessage.text
			}

			chatView.timeLabel?.text = timeLabelDateFormatter.string(from: chatMessage.date)

			delegate?.chatController(self, prepareChatView: chatView)
		}

		return cell
	}
}
