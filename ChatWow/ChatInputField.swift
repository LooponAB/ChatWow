//
//  ChatInputField.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 27/09/2017.
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
