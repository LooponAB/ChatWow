//
//  ChatWowViewController.swift
//  ChatDemo
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

public protocol ChatWowDataSource: class
{
	/// Total number of messages available to be displayed.
	func numberOfMessages(in chatController: ChatWowViewController) -> Int

	/// The message to be displayed at a certain position from the bottom of the view. Messages should be indexed by date, with the most
	/// recent message on index `0`.
	func chatController(_ chatController: ChatWowViewController, chatMessageWith index: Int) -> ChatMessage

	/// The read time stamp for the message. Return `nil` if the message has not yet been read.
	func chatController(_ chatController: ChatWowViewController, readDateForMessageWith index: Int) -> Date?

	/// Total number of pending messages to be displayed.
	func numberOfPendingMessages(in chatController: ChatWowViewController) -> Int

	/// The pending message to be displayed at a certain position from the bottom of the view.
	/// Please notice all "pending" messages appear below all "normal" messages.
	func chatController(_ chatController: ChatWowViewController, pendingChatMessageWith index: Int) -> ChatMessage
}

public protocol ChatWowDelegate: class
{
	/// Called when a chat bubble is about to be displayed. Can be used to setup custom chat bubble views.
	func chatController(_ chatController: ChatWowViewController, prepare cellView: ChatMessageView, for message: ChatMessage)

	/// Called when the user taps the "send" button, or taps/presses the return key on the keyboard.
	func chatController(_ chatController: ChatWowViewController, didInsertMessage message: String)

	/// Called when the user taps a message in the chat log.
	func chatController(_ chatController: ChatWowViewController, didTapMessageWith index: Int)

	/// Called when the user taps a pending message in the chat log.
	func chatController(_ chatController: ChatWowViewController, didTapPendingMessageWith index: Int)

	/// Lets the delegate calculate the estimated height for a custom message bubble type. Return nil for automatic calculation.
	func chatController(_ chatController: ChatWowViewController, estimatedHeightForMessageWith index: Int) -> CGFloat?
}

/// View controller that manages the presentation of a chat log. It is based on a `UITableView`, but masks (almost) all
/// of that interface away, in favor of a much simplified message-based interface.
///
/// `ChatWowViewController` tries to be very simple, and thus makes very few guesses: It always assumes the data sorce
/// is synchronized when its methods are invoked, and doesn't do any kind of message sorting.
///
/// What this means is that the client implementation has to do all of the work of indexing and sorting the messages.
/// However, this is not very complicated as long as your messages can't be reordered after being inserted in the chat
/// log. If any of this behavior is required in your implementation, then ChatWow is (currently) not suitable for your
/// use case.
///
/// For instructions and more information on how to use this class, please see the README.md file.
open class ChatWowViewController: UIViewController
{
	private var cachedCount: Int = 0
	private var cachedPendingCount: Int = 0
	private let _inputController: ChatInputViewController = ChatInputViewController.make()
	private var firstLoadHappened = false
	private var lastReadMessageInfo: (index: Int, date: Date)? = nil

	// Constraints
	private var bottomConstraint: NSLayoutConstraint? = nil
	private var bottomSafeAreaConstraint: NSLayoutConstraint? = nil

	open weak var dataSource: ChatWowDataSource? = nil
	open weak var delegate: ChatWowDelegate? = nil

	/// The color used to fill the message bubbles from "their" messages.
	open var bubbleColorTheirs: UIColor = #colorLiteral(red: 0.8817413449, green: 0.8817413449, blue: 0.8817413449, alpha: 1)

	/// The color used to fill the message bubbles from "our" messages.
	open var bubbleColorMine: UIColor = #colorLiteral(red: 0.004275974818, green: 0.478739202, blue: 0.9988952279, alpha: 1)

	/// The table view used to render the chat. Don't call `reloadSections(_:with:)` or `reloadRows(at:with:)`,
	/// as those methods are disabled.
	open let tableView: UITableView = ChatTableView(frame: CGRect(x: 0, y: 0, width: 320, height: 240), style: .plain)

	private lazy var readDateFormatter: DateFormatter =
		{
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.timeStyle = .short
			return formatter
		}()

	private lazy var messageDateFormatter: DateFormatter =
		{
			let formatter = DateFormatter()
			formatter.dateStyle = .none
			formatter.timeStyle = .short
			return formatter
		}()

	private var keyboardSpacerConstraint: NSLayoutConstraint?
	{
		return bottomConstraint
	}

	open var inputController: ChatInputViewController
	{
		return _inputController
	}

	public lazy var defaultTextMessageCellAttributes: [NSAttributedStringKey: Any] =
		{
			let paragraph = NSMutableParagraphStyle()
			paragraph.lineBreakMode = .byWordWrapping

			return [
				.font: UIFont.systemFont(ofSize: 16.0),
				.paragraphStyle: paragraph
			]
		}()

	public lazy var defaultEmojiMessageCellAttributes: [NSAttributedStringKey: Any] =
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

		if #available(iOS 11.0, *)
		{
			let safeAreaBottom = view.safeAreaLayoutGuide.bottomAnchor
			bottomSafeAreaConstraint = safeAreaBottom.constraint(equalTo: inputController.inputField.bottomAnchor, constant: 5)
			bottomSafeAreaConstraint?.isActive = true
		}
		else
		{
			inputController.view.bottomAnchor.constraint(equalTo: inputController.inputField.bottomAnchor, constant: 5).isActive = true
		}

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

		if #available(iOS 11.0, *)
		{
			bottomConstraint.constant = moveUp ? keyboardHeight : 0

			bottomSafeAreaConstraint?.isActive = false

			if moveUp
			{
				let bottomAnchor = inputController.view.bottomAnchor
				let constant = (keyboardHeight == 0 ? view.safeAreaInsets.bottom : 0) + 5
				bottomSafeAreaConstraint = bottomAnchor.constraint(equalTo: inputController.inputField.bottomAnchor, constant: constant)
			}
			else
			{
				let safeAreaBottom = view.safeAreaLayoutGuide.bottomAnchor
				bottomSafeAreaConstraint = safeAreaBottom.constraint(equalTo: inputController.inputField.bottomAnchor, constant: 5)
			}

			bottomSafeAreaConstraint?.isActive = true
		}
		else
		{
			bottomConstraint.constant = moveUp ? keyboardHeight : 0
		}

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

		for index in 0..<cachedCount
		{
			if let message = dataSource?.chatController(self, chatMessageWith: index),
			   !(message is ChatAnnotationMessage),
			   message.side == .mine,
			   let readDate = dataSource?.chatController(self, readDateForMessageWith: index)
			{
				lastReadInfo = (index, readDate)
				break
			}
		}

		return lastReadInfo
	}

	/// Calling this method while some table view animations are happening can cause an ugly glitch. To prevent this, call
	/// `setNeedsUpdateReadInfo()` instead, as that method schedules this update as a CATransaction completion callback.
	private func doUpdateReadInfo()
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
		else
		{
			lastReadMessageInfo = newReadInfo
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
}

extension ChatWowViewController: ChatInputViewControllerDelegate
{
	public func userDidSendMessage(_ message: String)
	{
		delegate?.chatController(self, didInsertMessage: message)
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
	/// Informs the chat controller that new messages have been added to the data source, and that they should be appended to the chat
	/// history. Make sure the data source will return the **new** message count when this method is called, as it will automatically
	/// deal with the message count offset.
	open func insert(newMessages count: Int, at index: Int = 0, scrollToBottom: Bool = false, animation: UITableViewRowAnimation = .left)
	{
		guard count > 0, let total = dataSource?.numberOfMessages(in: self) else
		{
			return
		}

		var indexPaths = [IndexPath]()

		for i in total - count ..< total
		{
			indexPaths.append(IndexPath(row: i + (lastReadMessageInfo != nil ? 1 : 0) - index, section: 0))
		}

		if let readInfo = lastReadMessageInfo
		{
			lastReadMessageInfo = (index: readInfo.index + count, date: readInfo.date)
		}

		tableView.insertRows(at: indexPaths, with: animation)

		if scrollToBottom
		{
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
				self.scrollToBottom(animated: true)
			})
		}

		cachedCount = total
	}

	/// Inserts a new pending message. Pending messages are displayed with a reduced opacity compared to "normal" messages, and always
	/// below them in the chat log. Make sure the data source will return the **new** message count when this method is called, as it will
	/// automatically deal with the message count offset.
	open func insert(pendingMessages count: Int, scrollToBottom: Bool = false, animation: UITableViewRowAnimation = .bottom)
	{
		guard count > 0, let total = dataSource?.numberOfPendingMessages(in: self) else
		{
			return
		}

		var indexPaths = [IndexPath]()

		for i in total - count ..< total
		{
			indexPaths.append(IndexPath(row: i, section: 1))
		}

		tableView.insertRows(at: indexPaths, with: animation)

		if scrollToBottom
		{
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
				self.scrollToBottom(animated: true)
			})
		}

		cachedPendingCount = total
	}

	/// Removes a message from the chat log. Make sure all data source methods return the "new" values upon calling this method,
	/// as if the message has already been removed in the data source.
	open func remove(messageAt index: Int)
	{
		if let indexPath = indexPath(for: .normal(index))
		{
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}

	/// Removes a pending message from the chat log. Make sure all data source methods return the "new" values upon calling this method,
	/// as if the message has already been removed in the data source.
	open func remove(pendingMessageAt index: Int)
	{
		if let indexPath = indexPath(for: .pending(index))
		{
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}

	/// Moves a pending message identified by `pendingIndex` to the normal chat log, and inserts it at `index`. Make sure all data source
	/// methods return the "new" values upon calling this method, as if the message has already been moved in the data source.
	open func commitPendingMessage(with pendingIndex: Int, to index: Int)
	{
		guard let dataSource = self.dataSource else
		{
			return
		}

		cachedCount = dataSource.numberOfMessages(in: self)

		if let readInfo = lastReadMessageInfo
		{
			lastReadMessageInfo = (index: readInfo.index + 1, date: readInfo.date)
		}

		let messageIndex = MessageIndex.normal(index)

		guard
			let pendingIndexPath = indexPath(for: .pending(pendingIndex)),
			let messageIndexPath = indexPath(for: messageIndex)
		else
		{
			print("Bad configuration: can't move pending message!")
			return
		}

		cachedPendingCount = dataSource.numberOfPendingMessages(in: self)

		tableView.moveRow(at: pendingIndexPath, to: messageIndexPath)

		// Wait for table view move animation
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35)
			{
				[weak self] in

				// Recalculate index path, as it might have changed in the meantime.
				if let indexPath = self?.indexPath(for: messageIndex)
				{
					self?.tableView.reloadRows(at: [indexPath], with: .fade)
				}
			}
	}

	/// Informs the chat controller that the last read message has changed. This will cause the chat controller to look for the most
	/// recently message again and then to move the "chat read" label to the appropriate position in the chat log.
	open func setNeedsUpdateReadInfo()
	{
		CATransaction.setCompletionBlock
			{
				[weak self] in self?.doUpdateReadInfo()
			}
	}

	/// Informs the chat controller that the message at a certain index has been updated for whatever reason. This will cause the
	/// controller to update the contents of that message on the chat log.
	open func updateMessage(at index: Int)
	{
		guard let indexPath = indexPath(for: .normal(index)) else
		{
			return
		}

		tableView.reloadRows(at: [indexPath], with: .fade)
	}

	/// Informs the chat controller that the pending message at a certain index has been updated for whatever reason. This will cause the
	/// controller to update the contents of that message on the chat log.
	open func updatePendingMessage(at index: Int)
	{
		guard let indexPath = indexPath(for: .pending(index)) else
		{
			return
		}

		tableView.reloadRows(at: [indexPath], with: .fade)
	}

	/// Causes the chat view to scroll to the bottom of the chat log, thus displaying the most recent messages.
	open func scrollToBottom(animated: Bool)
	{
		if cachedPendingCount > 0, let indexPath = indexPath(for: .pending(0))
		{
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
		}
		else if let indexPath = indexPath(for: .normal(0))
		{
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
		}
	}

	/// Clears the input field contents.
	open func clearInput()
	{
		inputController.inputField.text = ""
	}
}

internal enum MessageIndex
{
	case normal(Int)
	case readAnnotation(Date)
	case pending(Int)
}

extension ChatWowViewController: ChatTableViewDelegate, UITableViewDataSource
{
	/// This is where the magic of showing messages from top to bottom happens. We need to flip the default indexPath ordering (which
	/// is 0..<count) to the inverted chat message ordering (which is (count-1)...0). On top of that we need to account for the extra
	/// rows generated by ChatWow that display the "read" info label.
	private func chatMessageIndex(for indexPath: IndexPath) -> MessageIndex
	{
		if indexPath.section == 1
		{
			return .pending(cachedPendingCount - indexPath.row - 1)
		}
		else if let lastReadInfo = lastReadMessageInfo
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

		case .pending(let index):
			let row = cachedPendingCount - index
			if row > 0
			{
				return IndexPath(row: row - 1, section: 1)
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
		cachedPendingCount = dataSource?.numberOfPendingMessages(in: self) ?? 0
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
		return 2
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if section == 0
		{
			cachedCount = dataSource?.numberOfMessages(in: self) ?? 0
			return cachedCount + (lastReadMessageInfo != nil ? 1 : 0)
		}
		else
		{
			cachedPendingCount = dataSource?.numberOfPendingMessages(in: self) ?? 0
			return cachedPendingCount
		}
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		guard let dataSource = self.dataSource else
		{
			return UITableViewCell(style: .default, reuseIdentifier: "blank_cell")
		}

		let chatIndex = chatMessageIndex(for: indexPath)
		let chatMessage: ChatMessage
		let transluscent: Bool

		switch chatIndex
		{
		case .readAnnotation(let date):
			let readLabel = String(format: NSLocalizedString("Read %@", comment: ""), readDateFormatter.string(from: date))
			chatMessage = ChatReadAnnotationMessage(text: readLabel, side: .mine, date: date)
			transluscent = false

		case .normal(let index):
			chatMessage = dataSource.chatController(self, chatMessageWith: index)
			transluscent = false

		case .pending(let index):
			chatMessage = dataSource.chatController(self, pendingChatMessageWith: index)
			transluscent = true
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
				chatView.chatImageView?.maximumSize = image.size.aspectRect(maximumSize: view.maxImageInCellSize)
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

			chatView.transluscentView?.alpha = transluscent ? 0.5 : 1.0

			if chatMessage.hasError
			{
				chatView.hasError = true
			}
			else
			{
				chatView.hasError = false
			}

			delegate?.chatController(self, prepare: chatView, for: chatMessage)
		}

		return cell
	}

	// Tries to estimate the cell height only for cell types whose behavior we can predict.
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
	{
		guard let dataSource = self.dataSource, let delegate = self.delegate else
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
			// Give a chance for the delegate to calculate heights of any custom message cells.
			if let delegateHeight = delegate.chatController(self, estimatedHeightForMessageWith: index)
			{
				return delegateHeight
			}

			// Otherwise keep on going with our logic.
			chatMessage = dataSource.chatController(self, chatMessageWith: index)

		case .pending(let index):
			chatMessage = dataSource.chatController(self, pendingChatMessageWith: index)
		}

		if let textMessage = chatMessage as? ChatTextMessage
		{
			let maxSize = CGSize(width: view.bounds.width - 108.0, height: CGFloat.greatestFiniteMagnitude)

			if textMessage is ChatAnnotationMessage
			{
				/// Annotation rows have a fixed height
				return 23.5
			}
			else if textMessage.useBigEmoji
			{
				let size = (textMessage.text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading],
				                                                       attributes: defaultEmojiMessageCellAttributes, context: nil).size
				return size.height.rounded()
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
			return imageMessage.image.size.aspectRect(maximumSize: view.maxImageInCellSize).height + 8.0
		}
		else
		{
			return UITableViewAutomaticDimension
		}
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		guard let delegate = self.delegate else
		{
			return
		}

		switch chatMessageIndex(for: indexPath)
		{
		case .normal(let index):
			delegate.chatController(self, didTapMessageWith: index)

		case .pending(let index):
			delegate.chatController(self, didTapPendingMessageWith: index)

		default:
			break
		}
	}
}

private extension UIView
{
	var maxImageInCellSize: CGSize
	{
		return CGSize(width: bounds.size.width - 120.0, height: 300.0)
	}
}
