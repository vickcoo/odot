//
//  ViewController.swift
//  odot
//
//  Created by vick on 2023/11/2.
//

import UIKit

class ToDoListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    var toDoItems = ToDoItems()

    let searchController = UISearchController(searchResultsController: nil)
    var filteredToDoItems: [ToDoItem] = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.ShowDetail {
            let destination = segue.destination as! UINavigationController
            let detailViewController = destination.viewControllers.first! as! ToDoDetailViewController
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                detailViewController.todoItem = getCurrentToDoItem(by: selectedIndexPath.row)
            }
        } else if segue.identifier == SegueIdentifier.AddDetail {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func saveUnwindSegue(segue: UIStoryboardSegue) {
        let source = segue.source as! ToDoDetailViewController
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // update this to-do item.
            let index = toDoItems.getIndexBy(target: source.todoItem)
            toDoItems.items[index] = source.todoItem
            
            if isFiltering {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    filteredToDoItems[selectedIndexPath.row] = source.todoItem
                }
            }
            
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            
        } else {
            // add a new to-do item.
            let newIndexPath: IndexPath
            
            if isFiltering {
                newIndexPath = IndexPath(row: filteredToDoItems.count, section: 0)
                filteredToDoItems.append(source.todoItem)
            } else {
                newIndexPath = IndexPath(row: toDoItems.items.count, section: 0)
            }
            
            toDoItems.items.append(source.todoItem)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        
        saveData()
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            // turn off editing mode.
            tableView.setEditing(false, animated: true)
            editButton.title = String(localized: "Edit")
            addButton.isEnabled = true
        } else {
            // turn on editing mode.
            tableView.setEditing(true, animated: true)
            editButton.title = String(localized: "Done")
            addButton.isEnabled = false
        }
    }
}

extension ToDoListViewController {
    func saveData() {
        toDoItems.save()
        setNotifications()
    }
    
    func loadData() {
        toDoItems.load { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func setupUserInterface() {
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        loadData()
    }
    
    func setNotifications() {
        guard toDoItems.items.isEmpty == false else { return }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for i in 0..<toDoItems.items.count {
            let item = toDoItems.items[i]
            if item.isReminderOn && item.isCompleted == false {
                toDoItems.items[i].notificationID = LocalNotificationManager.setCalendarNotification(title: item.title, subtitle: "", body: item.note, badgeNumber: nil, sound: .default, date: item.date)
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredToDoItems = toDoItems.items.filter({ item in
            return item.title.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func getCurrentToDoItem(by index: Int) -> ToDoItem {
        let toDoItem: ToDoItem
        
        if isFiltering {
            toDoItem = filteredToDoItems[index]
        } else {
            toDoItem = toDoItems.items[index]
        }
        
        return toDoItem
    }
    
    /// Update specific to-do item in `toDoItems`
    /// - Parameter item: Use this to-do item to update item in `toDoItems`
    func syncOriginToDoItem(by item: ToDoItem) {
        let index = self.toDoItems.getIndexBy(target: item)
        self.toDoItems.items[index] = item
    }
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        
        if isFiltering {
            count = filteredToDoItems.count
        } else {
            count = toDoItems.items.count
        }
        
        if count == 0 {
            let title: String
            let message: String
            let image: UIImage
            
            if isFiltering {
                title = String(localized: "Not Found")
                message = String(localized: "Try to type another word")
                image = UIImage(systemName: "magnifyingglass")!
            } else {
                title = String(localized: "No Data")
                message = String(localized: "Hurry up! add your first to do")
                image = UIImage(systemName: "hand.wave.fill")!
            }
            
            tableView.setEmptyView(title: title, message: message, image: image)
            editButton.isEnabled = false
        } else {
            tableView.removeEmptyView()
            editButton.isEnabled = true
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as? TodoTableViewCell else { return UITableViewCell() }
        let toDoItem: ToDoItem = getCurrentToDoItem(by: indexPath.row)
        cell.delegate = self
        cell.todoItem = toDoItem
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = toDoItems.items[sourceIndexPath.row]
        toDoItems.items.remove(at: sourceIndexPath.row)
        toDoItems.items.insert(item, at: destinationIndexPath.row)
        saveData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isFiltering {
                let target = filteredToDoItems[indexPath.row]
                filteredToDoItems.remove(at: indexPath.row)
                let removeIndex = toDoItems.getIndexBy(target: target)
                toDoItems.items.remove(at: removeIndex)
            } else {
                toDoItems.items.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isCompleted: Bool = getCurrentToDoItem(by: indexPath.row).isCompleted
        let completeTitle = isCompleted ? String(localized: "Undone") : String(localized: "Done")
        
        let doneAction = UIContextualAction(style: .normal, title: completeTitle) { action, view, completionHandler in
            self.toggleCheckBox(indexPath: indexPath)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.saveData()
            completionHandler(true)
        }
        
        doneAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
}

extension ToDoListViewController: TodoTableViewCellDelegate {
    func toggleCheckBox(indexPath: IndexPath) {
        if isFiltering {
            filteredToDoItems[indexPath.row].isCompleted.toggle()
            let filteredToDoItem = filteredToDoItems[indexPath.row]
            syncOriginToDoItem(by: filteredToDoItem)
        } else {
            toDoItems.items[indexPath.row].isCompleted.toggle()
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        saveData()
    }
    
    func toggleCheckBox(sender: TodoTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            toggleCheckBox(indexPath: selectedIndexPath)
        }
    }
}

extension ToDoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        editButton.isEnabled = !isFiltering
    }
}

enum SegueIdentifier {
    static let ShowDetail = "ShowDetail"
    static let AddDetail = "AddDetail"
    static let SaveToDoItem = "SaveToDoItem"
}
