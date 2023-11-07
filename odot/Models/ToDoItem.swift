//
//  TodoItem.swift
//  odot
//
//  Created by vick on 2023/11/2.
//

import Foundation

struct ToDoItem: Codable, Equatable {
    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return lhs.title == rhs.title
            && lhs.date == rhs.date
            && lhs.note == rhs.note
            && lhs.isCompleted == rhs.isCompleted
            && lhs.isReminderOn == rhs.isReminderOn
    }
    
    var title: String
    var date: Date
    var note: String
    var isCompleted: Bool
    var isReminderOn: Bool
    var notificationID: String?
    
    init(title: String = "", date: Date, note: String = "", isCompleted: Bool = false, isReminderOn: Bool = false) {
        self.title = title
        self.date = date
        self.note = note
        self.isCompleted = isCompleted
        self.isReminderOn = isReminderOn
    }
}
