//
//  ChatKeyboardHelperView.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 27/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

protocol ChatKeyboardHelperViewDelegate: class
{
	func keyboardHelperView(didChangePosition verticalPosition: CGFloat)
}

class ChatKeyboardHelperView: UIView
{
	weak var delegate: ChatKeyboardHelperViewDelegate? = nil

	override func didMoveToSuperview()
	{
		super.didMoveToSuperview()

		superview?.addObserver(self, forKeyPath: "center", options: [], context: nil)
	}

	override func removeFromSuperview()
	{
		superview?.removeObserver(self, forKeyPath: "center")

		super.removeFromSuperview()
	}

	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?)
	{
		if keyPath == "center", (object as? UIView) === superview, let frame = superview?.frame, let delegate = self.delegate
		{
			delegate.keyboardHelperView(didChangePosition: frame.origin.y)
		}
		else
		{
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
}
