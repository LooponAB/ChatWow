//
//  ChatKeyboardHelperView.swift
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
