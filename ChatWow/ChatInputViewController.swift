//
//  ChatInputViewController.swift
//  ChatWowDemo
//
//  Created by Bruno Resende on 27/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

public protocol ChatInputViewControllerDelegate: class
{
	func userDidSendMessage(_ message: String)
}

open class ChatInputViewController: UIViewController
{
	@IBOutlet weak var inputField: ChatInputField!

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
