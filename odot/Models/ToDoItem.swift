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
    
    var id: String
    var title: String
    var date: Date
    var note: String
    var isCompleted: Bool
    var isReminderOn: Bool
    var notificationID: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.title = try container.decode(String.self, forKey: .title)
        self.date = try container.decode(Date.self, forKey: .date)
        self.note = try container.decode(String.self, forKey: .note)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        self.isReminderOn = try container.decode(Bool.self, forKey: .isReminderOn)
        self.notificationID = try container.decodeIfPresent(String.self, forKey: .notificationID)
    }
    
    init(id: String = UUID().uuidString, title: String = "", date: Date, note: String = "", isCompleted: Bool = false, isReminderOn: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.note = note
        self.isCompleted = isCompleted
        self.isReminderOn = isReminderOn
    }
}
