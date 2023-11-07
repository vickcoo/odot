//
//  TodoTableViewCell.swift
//  odot
//
//  Created by vick on 2023/11/2.
//

import UIKit

protocol TodoTableViewCellDelegate {
    func toggleCheckBox(sender: TodoTableViewCell)
}

class TodoTableViewCell: UITableViewCell {

    @IBOutlet var checkButton: UIButton!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var notificationSymbol: UIImageView!
    
    static let identifier = "ItemCell"
    var delegate: TodoTableViewCellDelegate?
    
    var todoItem: ToDoItem! {
        didSet {
            itemLabel.text = todoItem.title
            checkButton.isSelected = todoItem.isCompleted
            notificationSymbol.isHidden = !todoItem.isReminderOn
        }
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        
        delegate.toggleCheckBox(sender: self)
    }
    
}
