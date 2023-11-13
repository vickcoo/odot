//
//  TodoItems.swift
//  odot
//
//  Created by vick on 2023/11/2.
//

import Foundation
import OSLog

class ToDoItems {
    
    private var logger: Logger!
    
    var items: [ToDoItem] = []
    
    init() {
        logger = Logger()
    }
    
    /// Load data to `items`
    func load(completed: () -> Void) {
        let directoryURL = URL.documentsDirectory
        let documentURL = directoryURL.appending(components: "todo").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: documentURL) else { return }
        
        do {
            let jsonDecoder = JSONDecoder()
            try items = jsonDecoder.decode(Array<ToDoItem>.self, from: data)
        } catch {
            logger.error("Couldn't load data of toDoItems from: \(documentURL.absoluteString)")
        }
        
        completed()
    }
    
    /// Save data as a json to local from `items`
    func save() {
        let directoryURL = URL.documentsDirectory
        let documentURL = directoryURL.appending(components: "todo").appendingPathExtension("json")
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(items)
        
        do {
            try data?.write(to: documentURL)
        } catch {
            logger.error( "Couldn't write data of toDoItems to: \(documentURL.absoluteString)")
        }
    }
    
    /// Get index of target to-do item
    /// - Parameter target: That's item which you want to find
    /// - Returns: Index
    func getIndexBy(target: ToDoItem) -> Int {
        var index: Int = -1
        for item in items {
            if item.id == target.id {
                index = items.firstIndex(of: item) ?? index
            }
        }
        
        return index
    }
}
