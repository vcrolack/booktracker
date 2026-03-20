//
//  AppTheme.swift
//  booktracker
//
//  Created by Victor rolack on 20-03-26.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system =  "Sistema"
    case light = "Claro"
    case dark = "Oscuro"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}
