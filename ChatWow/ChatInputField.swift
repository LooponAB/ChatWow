//
//  ChatInputField.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 27/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

@IBDesignable
class ChatInputField: UITextField
{
	@IBInspectable
	var borderRadius: CGFloat = 0.0
	{
		didSet
		{
			layer.cornerRadius = borderRadius
		}
	}

	@IBInspectable
	var borderWidth: CGFloat = 2.0
	{
		didSet
		{
			layer.borderWidth = borderWidth
		}
	}

	@IBInspectable
	var borderColor: UIColor = .clear
	{
		didSet
		{
			layer.borderColor = borderColor.cgColor
		}
	}

	override func textRect(forBounds bounds: CGRect) -> CGRect
	{
		return CGRect(x: bounds.origin.x + 12.0, y: bounds.origin.y, width: bounds.width - 26.0 - 12.0, height: bounds.height)
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect
	{
		return textRect(forBounds: bounds)
	}
}
