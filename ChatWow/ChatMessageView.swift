//
//  ChatMessageView.swift
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

/// The view used for each individual chat message.
open class ChatMessageView: UITableViewCell
{
	static let kErrorImageViewWidth: CGFloat = 32

	@IBOutlet open var chatLabel: UILabel?
	@IBOutlet open var timeLabel: UILabel?
	@IBOutlet open var chatImageView: ChatImageView?
	@IBOutlet open var errorImageView: UIImageView?
	@IBOutlet open var errorImageConstraint: NSLayoutConstraint?

	// A view that can be made transluscent (it can be a view already attached to another IBOutlet)
	@IBOutlet open var transluscentView: UIView?

	var hasError: Bool = false
	{
		didSet
		{
			errorImageConstraint?.constant = hasError ? ChatMessageView.kErrorImageViewWidth : 0.0
		}
	}

	open override var frame: CGRect
	{
		didSet
		{
			subviews.forEach({ $0.setNeedsDisplay() })
			setNeedsDisplay()
		}
	}
}
