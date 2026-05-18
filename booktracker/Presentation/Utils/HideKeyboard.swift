//
//  HideKeyboard.swift
//  booktracker
//
//  Created by Victor rolack on 18-05-26.
//

import UIKit
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
