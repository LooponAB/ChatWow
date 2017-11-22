//
//  ChatImageView.swift
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
open class ChatImageView: UIImageView
{
	lazy var maximumSize: CGSize =
	{
		return bounds.size
	}()

	override init(frame: CGRect)
	{
		super.init(frame: frame)

		setupMaskBubble()
	}

	override init(image: UIImage?)
	{
		super.init(image: image)

		setupMaskBubble()
	}

	override init(image: UIImage?, highlightedImage: UIImage?)
	{
		super.init(image: image, highlightedImage: highlightedImage)

		setupMaskBubble()
	}

	required public init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)

		setupMaskBubble()
	}

	private func setupMaskBubble()
	{
		mask = ChatBubbleView(frame: bounds)
		mask?.backgroundColor = .clear
		mask?.setNeedsDisplay()
	}

	override open var bounds: CGRect
	{
		didSet
		{
			mask?.frame = bounds
			mask?.setNeedsDisplay()
			setNeedsDisplay()
		}
	}

	@IBInspectable
	var legOnLeft: Bool
	{
		get
		{
			return (mask as? ChatBubbleView)?.legOnLeft ?? false
		}

		set
		{
			(mask as? ChatBubbleView)?.legOnLeft = newValue
		}
	}

	override open var intrinsicContentSize: CGSize
	{
		return image?.size.aspectRect(maximumSize: maximumSize) ?? maximumSize
	}
}

extension CGSize
{
	func aspectRect(maximumSize: CGSize) -> CGSize
	{
		if width > height
		{
			return CGSize(width: maximumSize.width, height: height * (maximumSize.width / width))
		}
		else
		{
			return CGSize(width: width * (maximumSize.height / height), height: maximumSize.height)
		}
	}
}
