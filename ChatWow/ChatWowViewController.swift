//
//  ChatWowViewController.swift
//  ChatDemo
//
//  Created by Bruno Resende on 26/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

public protocol ChatWowDataSource: class
{
	/// Total number of messages available to be displayed.
	func numberOfMessages(in chatController: ChatWowViewController) -> Int

	/// The message to be displayed at a certain position from the bottom of the view. Messages should be indexed by date, with the most
	/// recent message on index `0`.
	func chatController(_ chatController: ChatWowViewController, chatMessageWith index: Int) -> ChatMessage

	/// The read time stamp for the message. Return `nil` if the message has not yet been read.
	func chatController(_ chatController: ChatWowViewController, readDateForMessageWith index: Int) -> Date?
}

public protocol ChatWowDelegate: class
{
	/// Called when a chat bubble is about to be displayed. Can be used to setup custom chat bubble views.
	func chatController(_ chatController: ChatWowViewController, prepare cellView: ChatMessageView, for message: ChatMessage)

	/// Called when the user taps the "send" button, or taps/presses the return key on the keyboard.
	func chatController(_ chatController: ChatWowViewController, userDidInsertMessage message: String)
}

open class ChatWowViewController: UIViewController
{
	private var cachedCount: Int = 0
	private var bottomConstraint: NSLayoutConstraint? = nil
	private let _inputController: ChatInputViewController = ChatInputViewController.make()
	private var firstLoadHappened = false

//	private var extraMessages: [Int: ChatMessage] = [:]
	private var lastReadMessageInfo: (index: Int, date: Date)? = nil

	open weak var dataSource: ChatWowDataSource? = nil
	open weak var delegate: ChatWowDelegate? = nil

	/// The color used to fill the message bubbles from "their" messages.
	open var bubbleColorTheirs: UIColor = #colorLiteral(red: 0.8817413449, green: 0.8817413449, blue: 0.8817413449, alpha: 1)

	/// The color used to fill the message bubbles from "our" messages.
	open var bubbleColorMine: UIColor = #colorLiteral(red: 0.004275974818, green: 0.478739202, blue: 0.9988952279, alpha: 1)

	/// The table view used to render the chat. Don't call `reloadSections(_:with:)` or `reloadRows(at:with:)`, as those are disabled.
	open let tableView: UITableView = ChatTableView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), style: .plain)

	open lazy var readDateFormatter: DateFormatter =
		{
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.timeStyle = .short
			return formatter
		}()

	open lazy var messageDateFormatter: DateFormatter =
		{
			let formatter = DateFormatter()
			formatter.dateStyle = .none
			formatter.timeStyle = .short
			return formatter
		}()

	var keyboardSpacerConstraint: NSLayoutConstraint?
	{
		return bottomConstraint
	}

	open var inputController: ChatInputViewController
	{
		return _inputController
	}

	open func clearInput()
	{
		inputController.inputField.text = ""
	}

	private lazy var defaultTextMessageCellAttributes: [NSAttributedStringKey: Any] =
		{
			let paragraph = NSMutableParagraphStyle()
			paragraph.lineBreakMode = .byWordWrapping

			return [
				.font: UIFont.systemFont(ofSize: 15.0),
				.paragraphStyle: paragraph
			]
		}()

	private lazy var defaultEmojiMessageCellAttributes: [NSAttributedStringKey: Any] =
		{
			let paragraph = NSMutableParagraphStyle()
			paragraph.lineBreakMode = .byWordWrapping

			return [
				.font: UIFont.systemFont(ofSize: 40.0),
				.paragraphStyle: paragraph
			]
		}()

	open override func viewDidLoad()
	{
		super.viewDidLoad()

		view.addSubview(tableView)
		view.addSubview(inputController.view)

		tableView.translatesAutoresizingMaskIntoConstraints = false
		inputController.view.translatesAutoresizingMaskIntoConstraints = false
		inputController.delegate = self

		let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [],
		                                                 metrics: nil, views: ["tableView": tableView])
						+ NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputView]|", options: [],
														 metrics: nil, views: ["inputView": inputController.view])
						+ NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]", options: [],
														 metrics: nil, views: ["tableView": tableView])

		NSLayoutConstraint.activate(constraints)

		tableView.bottomAnchor.constraint(equalTo: inputController.view.bottomAnchor).isActive = true

		bottomConstraint = view.bottomAnchor.constraint(equalTo: inputController.view.bottomAnchor)
		bottomConstraint?.isActive = true

		tableView.dataSource = self
		tableView.delegate = self

		let bundle = Bundle(for: ChatMessageView.self)
		tableView.register(UINib(nibName: "ChatMessageMine", bundle: bundle), forCellReuseIdentifier: "chat_default_mine")
		tableView.register(UINib(nibName: "ChatMessageTheirs", bundle: bundle), forCellReuseIdentifier: "chat_default_theirs")
		tableView.register(UINib(nibName: "ChatImageMine", bundle: bundle), forCellReuseIdentifier: "chat_default_image_mine")
		tableView.register(UINib(nibName: "ChatImageTheirs", bundle: bundle), forCellReuseIdentifier: "chat_default_image_theirs")
		tableView.register(UINib(nibName: "ChatEmojiMessageMine", bundle: bundle), forCellReuseIdentifier: "chat_default_emoji_mine")
		tableView.register(UINib(nibName: "ChatEmojiMessageTheirs", bundle: bundle), forCellReuseIdentifier: "chat_default_emoji_theirs")
		tableView.register(UINib(nibName: "ChatInfoLineCell", bundle: bundle), forCellReuseIdentifier: "chat_default_info")
		tableView.register(UINib(nibName: "ChatInfoLineWithTimeCell", bundle: bundle), forCellReuseIdentifier: "chat_default_info_with_time")
		tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputController.view.bounds.height + 20.0, right: 0)
		tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: inputController.view.bounds.height, right: 0)
		tableView.backgroundColor = .white
		tableView.separatorStyle = .none
		tableView.keyboardDismissMode = .interactive

		setupKeyboardDismissalAnimations()
	}

	open override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		tableView.reloadData()
	}

	private func setupKeyboardDismissalAnimations()
	{
		NotificationCenter.default.addObserver(self, selector: #selector(ChatWowViewController.animateWithKeyboard(_:)),
		                                       name: Notification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ChatWowViewController.animateWithKeyboard(_:)),
		                                       name: Notification.Name.UIKeyboardWillHide, object: nil)

		let helperView = ChatKeyboardHelperView(frame: CGRect(x: 0, y: 0, width: 320, height: 0))
		helperView.delegate = self

		inputController.inputField.inputAccessoryView = helperView
	}

	@objc func animateWithKeyboard(_ notification: Notification)
	{
		guard let bottomConstraint = self.bottomConstraint else { return }

		let userInfo = notification.userInfo!
		let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
		let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
		let moveUp = notification.name == .UIKeyboardWillShow

		bottomConstraint.constant = moveUp ? keyboardHeight : 0

		let options = UIViewAnimationOptions(rawValue: curve << 16)
		UIView.animate(withDuration: duration, delay: 0, options: options, animations:
			{
				self.view.layoutIfNeeded()
				self.scrollToBottom(animated: true)
			}, completion: nil)
	}

	deinit
	{
		NotificationCenter.default.removeObserver(self)
	}

	private func reindexedLastReadMessage() -> (index: Int, date: Date)?
	{
		guard cachedCount > 0 else
		{
			return nil
		}

		var lastReadInfo: (Int, Date)? = nil

		for index in (0..<cachedCount).reversed()
		{
			if let message = dataSource?.chatController(self, chatMessageWith: index),
			   !(message is ChatAnnotationMessage),
			   message.side == .mine,
			   let readDate = dataSource?.chatController(self, readDateForMessageWith: index)
			{
				lastReadInfo = (index, readDate)
			}
		}

		return lastReadInfo
	}
}

extension ChatWowViewController: ChatInputViewControllerDelegate
{
	public func userDidSendMessage(_ message: String)
	{
		delegate?.chatController(self, userDidInsertMessage: message)
	}
}

extension ChatWowViewController: ChatKeyboardHelperViewDelegate
{
	func keyboardHelperView(didChangePosition verticalPosition: CGFloat)
	{
		if let windowHeight = view.window?.bounds.height, windowHeight >= verticalPosition
		{
			keyboardSpacerConstraint?.constant = windowHeight - verticalPosition
		}
	}
}

extension ChatWowViewController // Chat interface
{
	open func insertMessages(newMessages count: Int, scrollToBottom: Bool = false)
	{
		guard let total = dataSource?.numberOfMessages(in: self) else
		{
			return
		}

		var indexPaths = [IndexPath]()

		for i in total - count ..< total
		{
			indexPaths.append(IndexPath(row: i + (lastReadMessageInfo != nil ? 1 : 0), section: 0))
		}

		if let readInfo = lastReadMessageInfo
		{
			lastReadMessageInfo = (index: readInfo.index + count, date: readInfo.date)
		}

		tableView.insertRows(at: indexPaths, with: .left)

		if scrollToBottom
		{
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
				self.scrollToBottom(animated: true)
			})
		}
	}

	open func updateReadInfo()
	{
		let previousIndexPath = indexPath(for: .readAnnotation(Date()))
		let newReadInfo = reindexedLastReadMessage()

		if let indexPath = previousIndexPath, let readInfo = newReadInfo
		{
			// The index and dates are updated separately to prevent curruption of tableview indexPaths
			lastReadMessageInfo?.date = readInfo.date
			tableView.reloadRows(at: [indexPath], with: .fade)
			lastReadMessageInfo?.index = readInfo.index
		}

		if let previousIndexPath = previousIndexPath, let newIndexPath = indexPath(for: .readAnnotation(Date()))
		{
			tableView.moveRow(at: previousIndexPath, to: newIndexPath)
		}
		else if let newIndexPath = indexPath(for: .readAnnotation(Date()))
		{
			tableView.insertRows(at: [newIndexPath], with: .top)
		}
	}

	open func updateMessage(at index: Int)
	{
		guard let indexPath = indexPath(for: .normal(index)) else
		{
			return
		}

		tableView.reloadRows(at: [indexPath], with: .fade)
	}

	open func scrollToBottom(animated: Bool)
	{
		guard let indexPath = indexPath(for: .normal(0)) else { return }
		tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
	}
}

internal enum MessageIndex
{
	case normal(Int)
	case readAnnotation(Date)
}

extension ChatWowViewController: ChatTableViewDelegate, UITableViewDataSource
{
	/// This is where the magic of showing messages from top to bottom happens. We need to flip the default indexPath ordering (which
	/// is 0..<count) to the inverted chat message ordering (which is (count-1)...0). On top of that we need to account for the extra
	/// rows generated by ChatWow that display the "read" info label.
	private func chatMessageIndex(for indexPath: IndexPath) -> MessageIndex
	{
		if let lastReadInfo = lastReadMessageInfo
		{
			let row = cachedCount - indexPath.row

			if row == lastReadInfo.index
			{
				return .readAnnotation(lastReadInfo.date)
			}
			else if row < lastReadInfo.index
			{
				return .normal(row)
			}
			else
			{
				return .normal(row - 1)
			}
		}
		else
		{
			return .normal(cachedCount - indexPath.row - 1)
		}
	}

	private func indexPath(for messageIndex: MessageIndex) -> IndexPath?
	{
		switch messageIndex
		{
		case .normal(let index):
			let row = cachedCount - index

			if let lastReadIndex = lastReadMessageInfo?.index, index < lastReadIndex
			{
				return IndexPath(row: row, section: 0)
			}
			else if row > 0
			{
				return IndexPath(row: row - 1, section: 0)
			}
			else
			{
				return nil
			}

		case .readAnnotation(_):
			if let annotationIndex = lastReadMessageInfo?.index
			{
				return IndexPath(row: cachedCount - annotationIndex, section: 0)
			}
			else
			{
				return nil
			}
		}
	}

	func tableViewWillReloadData(_ tableView: ChatTableView)
	{
		lastReadMessageInfo = nil
		cachedCount = dataSource?.numberOfMessages(in: self) ?? 0
		lastReadMessageInfo = reindexedLastReadMessage()
	}

	func tableViewDidReloadData(_ tableView: ChatTableView)
	{
		if !firstLoadHappened && cachedCount > 0
		{
			firstLoadHappened = true
			scrollToBottom(animated: false)
		}
	}

	public func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		cachedCount = dataSource?.numberOfMessages(in: self) ?? 0
		return cachedCount + (lastReadMessageInfo != nil ? 1 : 0)
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		guard let dataSource = self.dataSource else
		{
			return UITableViewCell(style: .default, reuseIdentifier: "blank_cell")
		}

		let chatIndex = chatMessageIndex(for: indexPath)
		let chatMessage: ChatMessage

		switch chatIndex
		{
		case .readAnnotation(let date):
			let readLabel = String(format: NSLocalizedString("Read %@", comment: ""), readDateFormatter.string(from: date))
			chatMessage = ChatReadAnnotationMessage(text: readLabel, side: .mine, date: date)

		case .normal(let index):
			chatMessage = dataSource.chatController(self, chatMessageWith: index)
		}

		let cell = tableView.dequeueReusableCell(withIdentifier: chatMessage.viewIdentifier, for: indexPath)
		cell.selectionStyle = .none
		cell.tintColor = chatMessage.side == .mine ? bubbleColorMine : bubbleColorTheirs

		if let chatView = cell as? ChatMessageView
		{
			if let textMessage = chatMessage as? ChatTextMessage
			{
				chatView.chatLabel?.text = textMessage.text
			}
			else if let imageMessage = chatMessage as? ChatImageMessage
			{
				let image = imageMessage.image
				chatView.chatImageView?.image = image
				chatView.chatImageView?.maximumSize = image.size.aspectRect(maximumSize: tableView.maxImageInCellSize)
			}

			if chatMessage is ChatReadAnnotationMessage
			{
				chatView.chatLabel?.textAlignment = .right
			}
			else if chatMessage is ChatAnnotationMessage
			{
				chatView.chatLabel?.textAlignment = .center
			}

			if chatMessage.showTimestamp
			{
				chatView.timeLabel?.text = messageDateFormatter.string(from: chatMessage.date)
			}
			else
			{
				chatView.timeLabel?.text = nil
			}

			chatView.transluscentView?.alpha = chatMessage.showTransluscent ? 0.5 : 1.0

			delegate?.chatController(self, prepare: chatView, for: chatMessage)
		}

		return cell
	}

	// Tries to estimate the cell height only for cell types whose behavior we can predict.
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
	{
		guard let dataSource = self.dataSource else
		{
			return UITableViewAutomaticDimension
		}

		let chatIndex = chatMessageIndex(for: indexPath)
		let chatMessage: ChatMessage

		switch chatIndex
		{
		case .readAnnotation(_):
			/// The "read" row is an annotation row, with fixed height.
			return 24.0

		case .normal(let index):
			chatMessage = dataSource.chatController(self, chatMessageWith: index)
		}

		if let textMessage = chatMessage as? ChatTextMessage
		{
			let maxSize = CGSize(width: tableView.bounds.width - 108.0, height: CGFloat.greatestFiniteMagnitude)

			if textMessage is ChatAnnotationMessage
			{
				/// Annotation rows have a fixed height
				return 24.0
			}
			else if textMessage.useBigEmoji
			{
				let size = (textMessage.text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading],
				                                                       attributes: defaultEmojiMessageCellAttributes, context: nil).size
				return size.height
			}
			else
			{
				let size = (textMessage.text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading],
				                                                       attributes: defaultTextMessageCellAttributes, context: nil).size
				return size.height + 24.0
			}
		}
		else if let imageMessage = chatMessage as? ChatImageMessage
		{
			return imageMessage.image.size.aspectRect(maximumSize: tableView.maxImageInCellSize).height + 8.0
		}
		else
		{
			return UITableViewAutomaticDimension
		}
	}
}

private extension UITableView
{
	var maxImageInCellSize: CGSize
	{
		return CGSize(width: bounds.size.width - 120.0, height: 300.0)
	}
}
