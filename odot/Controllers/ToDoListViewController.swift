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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.ShowDetail {
            let destination = segue.destination as! UINavigationController
            let detailViewController = destination.viewControllers.first! as! ToDoDetailViewController
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                detailViewController.todoItem = toDoItems.items[selectedIndexPath.row]
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
            toDoItems.items[selectedIndexPath.row] = source.todoItem
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            // add a new to-do item.
            let newIndexPath = IndexPath(row: toDoItems.items.count, section: 0)
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
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDoItems.items.isEmpty {
            let title = String(localized: "No Data")
            let message = String(localized: "Hurry up! add your first to do.")
            tableView.setEmptyView(title: title, message: message)
            editButton.isEnabled = false
        } else {
            tableView.removeEmptyView()
            editButton.isEnabled = true
        }
        
        return toDoItems.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as? TodoTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.todoItem = toDoItems.items[indexPath.row]
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
            toDoItems.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeTitle = toDoItems.items[indexPath.row].isCompleted ? String(localized: "Undone") : String(localized: "Done")
        let doneAction = UIContextualAction(style: .normal, title: completeTitle) { action, view, completionHandler in
            self.toDoItems.items[indexPath.row].isCompleted.toggle()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            completionHandler(true)
        }
        
        doneAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
}

extension ToDoListViewController: TodoTableViewCellDelegate {
    func toggleCheckBox(sender: TodoTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            toDoItems.items[selectedIndexPath.row].isCompleted = !toDoItems.items[selectedIndexPath.row].isCompleted
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            saveData()
        }
    }
}

enum SegueIdentifier {
    static let ShowDetail = "ShowDetail"
    static let AddDetail = "AddDetail"
    static let SaveToDoItem = "SaveToDoItem"
}
