//
//  ChatTableView.swift
//  ChatWow
//
//  Created by Bruno Resende on 29/09/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import UIKit

class ChatTableView: UITableView
{
	override func reloadData()
	{
		if let chatTableDelegate = delegate as? ChatTableViewDelegate
		{
			chatTableDelegate.tableViewWillReloadData(self)
		}

		super.reloadData()
	}
}

protocol ChatTableViewDelegate: UITableViewDelegate
{
	func tableViewWillReloadData(_ tableView: ChatTableView)
}
