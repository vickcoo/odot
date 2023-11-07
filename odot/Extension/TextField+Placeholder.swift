//
//  TextField+Placeholder.swift
//  odot
//
//  Created by vick on 2023/11/3.
//

import Foundation
import UIKit

extension UITextView {
    /// Attach a placeholder
    ///
    /// You need to conform protocol of `UITextViewDelegate`,  implement function there are `textViewDidChange` and  `textViewDidEndEditing`
    ///
    ///```swift
    /// extension ToDoDetailViewController : UITextViewDelegate {
    ///     func textViewDidChange(_ textView: UITextView) {
    ///         textView.getPlaceholderLabel()?.isHidden = !textView.text.isEmpty
    ///     }
    ///     func textViewDidEndEditing(_ textView: UITextView) {
    ///         textView.getPlaceholderLabel()?.isHidden = !textView.text.isEmpty
    ///     }
    /// }
    ///```
    func attachPlaceholder() {
        guard self.getPlaceholderLabel() == nil else { return }
        
        let placeholderLabel = UILabel()
        placeholderLabel.accessibilityIdentifier = "UITextViewPlaceholderLabel"
        placeholderLabel.text = String(localized: "Type your note here ...")
        placeholderLabel.font = .systemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        self.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = .tertiaryLabel
        
        if let text = self.text {
            placeholderLabel.isHidden = !text.isEmpty
        } else {
            placeholderLabel.isHidden = false
        }
    }
    
    /// Get placeholder of UILabel, but you must run `appendPlaceholder` first, that important.
    /// - Returns: placeholder
    func getPlaceholderLabel() -> UILabel? {
        let filteredSubViews = self.subviews.filter {
            $0.accessibilityIdentifier == "UITextViewPlaceholderLabel"
        }
        
        if let placeholderLabel = filteredSubViews.first {
            return placeholderLabel as? UILabel
        }
        
        return nil
    }
    
    func updatePlaceholder() {
        guard let placeholderLabel = getPlaceholderLabel() else { return }
        placeholderLabel.isHidden = !text.isEmpty
    }
}
