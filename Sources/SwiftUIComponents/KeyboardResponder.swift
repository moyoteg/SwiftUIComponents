//
//  KeyboardResponder.swift
//  Common
//
//  Created by Moi Gutierrez on 1/21/20.
//

import Foundation
import SwiftUI
import Combine

#if os(iOS) || os(watchOS)

final class KeyboardResponder: ObservableObject {
    let didChange = PassthroughSubject<CGFloat, Never>()

    private var _center: NotificationCenter
    private(set) var AppStateHeight: CGFloat = 0 {
        didSet {
            didChange.send(AppStateHeight)
        }
    }

    init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        _center.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        print("keyboard will show")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            AppStateHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        print("keyboard will hide")
        AppStateHeight = 0
    }
}
#endif
