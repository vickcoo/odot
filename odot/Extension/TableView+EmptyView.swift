//
//  TableView+EmptyView.swift
//  odot
//
//  Created by vick on 2023/11/2.
//

import Foundation
import UIKit

extension UITableView {
    /// Display a message on the `UITableView` center, notice you need to call `removeEmptyView()` when table hasn't any row.
    func setEmptyView(title: String, message: String) {
        let backgroundView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .label
        backgroundView.addSubview(titleLabel)
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        backgroundView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -6),
            messageLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
        ])
        
        self.backgroundView = backgroundView
    }
    
    /// Clean the message that  you have set before by `setEmptyView(title: String, message: String)`
    func removeEmptyView() {
        self.backgroundView = nil
    }
}
