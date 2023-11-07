//
//  ToDoDetailViewController.swift
//  odot
//
//  Created by vick on 2023/11/2.
//

import UIKit

class ToDoDetailViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var reminderDatePicker: UIDatePicker!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var reminderSymbolImageView: UIImageView!
    
    var todoItem: ToDoItem!
    var newToDoItem: ToDoItem {
        return ToDoItem(title: titleTextField.text ?? "", date: reminderDatePicker.date, note: noteTextView.text, isCompleted: todoItem.isCompleted, isReminderOn: reminderSwitch.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if todoItem == nil {
            todoItem = ToDoItem(date: Date().addingTimeInterval(60*60)) // set notification after 1 hours as default.
            titleTextField.becomeFirstResponder()
        }

        setupUserInterface()
        notificationObserverRegister()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // save button tapped.
        todoItem = ToDoItem(title: titleTextField.text ?? "", date: reminderDatePicker.date, note: noteTextView.text, isCompleted: todoItem.isCompleted, isReminderOn: reminderSwitch.isOn)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        confirmToDismiss()
    }
    
    @IBAction func reminderSwitchValueChanged(_ sender: UISwitch) {
        if reminderSwitch.isOn {
            reminderDatePicker.isEnabled = true
            handleNotificationAuthorize()
        } else {
            reminderDatePicker.isEnabled = false
        }
        updateNotificationSymbol(isOn: reminderSwitch.isOn)
    }
}

extension ToDoDetailViewController {
    func setupUserInterface() {
        self.isModalInPresentation = true
        self.navigationController?.presentationController?.delegate = self
        
        titleTextField.delegate = self
        noteTextView.delegate = self
        noteTextView.attachPlaceholder()
        
        // add a 'Done' button to provide a function for hide keyboard.
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: String(localized: "Done"), style: .done, target: self, action: #selector(hideKeyboardDoneButtonTapped))
        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        noteTextView.inputAccessoryView = toolbar
        titleTextField.inputAccessoryView = toolbar
        
        titleTextField.text = todoItem.title
        reminderDatePicker.date = todoItem.date
        noteTextView.text = todoItem.note
        reminderSwitch.isOn = todoItem.isReminderOn
        updateNotificationSymbol(isOn: todoItem.isReminderOn)
        
        noteTextView.updatePlaceholder()
    }
    
    func notificationObserverRegister() {
        // Dynamic adjust view when keyboard show, hide and more.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // Hide keyboard when user tapped other position on the view.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    /// Update the notification symbol when you turn on.
    /// - Parameter isOn: turn on or off
    func updateNotificationSymbol(isOn: Bool) {
        if isOn {
            reminderSymbolImageView.image = UIImage(systemName: "bell.fill")
            reminderSymbolImageView.tintColor = .systemGreen
        } else {
            reminderSymbolImageView.image = UIImage(systemName: "bell.slash.fill")
            reminderSymbolImageView.tintColor = .red
        }
    }
    
    /// Request authorization of notification when user first used,
    /// If the authorization isn't granted popup a alert to provide function to open settings.
    func handleNotificationAuthorize() {
        LocalNotificationManager.authorizationStatus { status in
            switch status {
            case .notDetermined:
                LocalNotificationManager.autherizeLocalNotification()
            case .denied, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    LocalNotificationManager.openNotificationSettings(viewController: self)
                }
            case .authorized:
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    /// Popup confirm alert when data changed, otherwise just dismiss this view.
    func confirmToDismiss() {
        if self.todoItem != newToDoItem {
            let title = String(localized: "You have unsave data")
            let message = String(localized: "Do you want to discard or save edited data?")
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: String(localized: "Discard"), style: .destructive) { [weak self] action in
                self?.dismiss(animated: true)
            })
            alertController.addAction(UIAlertAction(title: String(localized: "Save"), style: .default) { [weak self] action in
                self?.todoItem = self?.newToDoItem
                self?.performSegue(withIdentifier: SegueIdentifier.SaveToDoItem, sender: nil)
            })
            alertController.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .cancel))
            
            present(alertController, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func adjustForKeyboard(_ notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextView.contentInset = .zero
        } else {
            noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        noteTextView.verticalScrollIndicatorInsets = noteTextView.contentInset
        noteTextView.scrollRangeToVisible(noteTextView.selectedRange)
    }
    
    @objc func hideKeyboardDoneButtonTapped() {
        self.view.endEditing(true)
    }
}

extension ToDoDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            return noteTextView.becomeFirstResponder()
        }
        
        return false
    }
}

extension ToDoDetailViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.updatePlaceholder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.updatePlaceholder()
    }
}

extension ToDoDetailViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmToDismiss()
    }
}
