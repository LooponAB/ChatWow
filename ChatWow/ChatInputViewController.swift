//
//  ChatInputViewController.swift
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

public protocol ChatInputViewControllerDelegate: class
{
	func userDidSendMessage(_ message: String)
}

open class ChatInputViewController: UIViewController
{
	@IBOutlet weak var inputField: ChatInputField!
	@IBOutlet weak var sendButton: UIButton!

	weak var delegate: ChatInputViewControllerDelegate? = nil

	override open func viewDidLoad()
	{
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	/// Whether the input controller is enabled.
	public var isEnabled: Bool
	{
		get { return inputField.isEnabled }
		set
		{
			inputField.isEnabled = newValue
			sendButton.isEnabled = newValue
		}
	}

	/// Sets the placeholder string for the input text field.
	public func setPlaceholder(_ prompt: String)
	{
		inputField.placeholder = prompt
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func send(_ sender: Any)
	{
		delegate?.userDidSendMessage(inputField.text ?? "")
	}
}

extension ChatInputViewController: UITextFieldDelegate
{
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		send(textField)
		return true
	}
}

extension ChatInputViewController
{
	static func make() -> ChatInputViewController
	{
		return ChatInputViewController(nibName: "ChatInputViewController", bundle: Bundle(for: ChatInputViewController.self))
	}
}
