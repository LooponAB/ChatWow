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
	func chatController(_ chatController: ChatWowViewController, chatMessageWithIndex index: Int) -> ChatMessage
}

public protocol ChatWowDelegate: class
{
	/// Called when a chat bubble is about to be displayed. Can be used to setup custom chat bubble views.
	func chatController(_ chatController: ChatWowViewController, prepareChatView cellView: ChatMessageView)

	/// Called when the user taps the "send" button, or taps/presses the return key on the keyboard.
	func chatController(_ chatController: ChatWowViewController, userDidInsertMessage message: String)
}

open class ChatWowViewController: UIViewController
{
	private var cachedCount: Int = 0
	private var bottomConstraint: NSLayoutConstraint? = nil
	private let _inputController: ChatInputViewController = ChatInputViewController.make()

	open weak var dataSource: ChatWowDataSource? = nil
	open weak var delegate: ChatWowDelegate? = nil

	/// The color used to fill the message bubbles from "their" messages.
	open var bubbleColorTheirs: UIColor = #colorLiteral(red: 0.8817413449, green: 0.8817413449, blue: 0.8817413449, alpha: 1)

	/// The color used to fill the message bubbles from "our" messages.
	open var bubbleColorMine: UIColor = #colorLiteral(red: 0.004275974818, green: 0.478739202, blue: 0.9988952279, alpha: 1)

	open let tableView: UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), style: .plain)

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

	private lazy var timeLabelDateFormatter: DateFormatter =
		{
			let formatter = DateFormatter()
			formatter.dateStyle = .none
			formatter.timeStyle = .short
			return formatter
		}()

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

	private lazy var defaultAnnotationCellAttributes: [NSAttributedStringKey: Any] =
		{
			let paragraph = NSMutableParagraphStyle()
			paragraph.lineBreakMode = .byWordWrapping

			return [
				.font: UIFont.systemFont(ofSize: 10.0),
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
		tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputController.view.bounds.height + 20.0, right: 0)
		tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: inputController.view.bounds.height, right: 0)
		tableView.backgroundColor = .white
		tableView.separatorStyle = .none
		tableView.keyboardDismissMode = .interactive
		tableView.reloadData()

		setupKeyboardDismissalAnimations()
	}

	open override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		scrollToBottom(animated: false)
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
			indexPaths.append(IndexPath(row: i, section: 0))
		}

		tableView.insertRows(at: indexPaths, with: .left)

		if scrollToBottom
		{
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
				self.scrollToBottom(animated: true)
			})
		}
	}

	func scrollToBottom(animated: Bool)
	{
		guard let indexPath = indexPath(for: 0) else { return }
		tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
	}
}

extension ChatWowViewController: UITableViewDelegate, UITableViewDataSource
{
	/// This is where the magic of showing messages from top to bottom happens. We need to flip the default indexPath ordering (which
	/// is 0..<count) to the inverted chat message ordering (which is (count-1)...0).
	private func chatMessageIndex(for indexPath: IndexPath) -> Int
	{
		return cachedCount - indexPath.row - 1
	}

	private func indexPath(for messageIndex: Int) -> IndexPath?
	{
		let row = (cachedCount - 1) - messageIndex

		guard row >= 0 else
		{
			return nil
		}

		return IndexPath(row: row, section: 0)
	}

	public func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		cachedCount = dataSource?.numberOfMessages(in: self) ?? 0
		return cachedCount
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let index = chatMessageIndex(for: indexPath)
		guard let chatMessage = dataSource?.chatController(self, chatMessageWithIndex: index) else
		{
			return UITableViewCell(style: .default, reuseIdentifier: "blank_cell")
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

			chatView.timeLabel?.text = timeLabelDateFormatter.string(from: chatMessage.date)

			delegate?.chatController(self, prepareChatView: chatView)
		}

		return cell
	}

	// Tries to estimate the cell height only for cell types whose behavior we can predict.
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
	{
		let index = chatMessageIndex(for: indexPath)
		guard let chatMessage = dataSource?.chatController(self, chatMessageWithIndex: index) else
		{
			return UITableViewAutomaticDimension
		}

		if let textMessage = chatMessage as? ChatTextMessage
		{
			let maxSize = CGSize(width: tableView.bounds.width - 108.0, height: CGFloat.greatestFiniteMagnitude)

			if textMessage is ChatAnnotationMessage
			{
				let size = (textMessage.text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading],
				                                                       attributes: defaultAnnotationCellAttributes, context: nil).size
				return size.height + 10.0
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
