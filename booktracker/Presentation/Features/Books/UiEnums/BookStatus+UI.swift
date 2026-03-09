//
//  BookStatus+UI.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

extension BookStatus {
    var uiColor: Color {
        switch self {
        case .wishlist: return .pink
        case .toRead: return .gray
        case .reading: return .blue
        case .finalized: return .green
        case .abandoned: return .red
        }
    }
    
    var uiIcon: String {
        switch self {
        case .wishlist: return "heart.fill"
        case .toRead: return "bookmark.fill"
        case .reading: return "book.fill"
        case .finalized: return "checkmark.seal.fill"
        case .abandoned: return "xmark.circle.fill"
        }
    }
    
    var uiLabel: String {
        switch self {
        case .wishlist: return "Deseados"
        case .toRead: return "Por leer"
        case .reading: return "Leyendo"
        case .finalized: return "Leído"
        case .abandoned: return "Abandonado"
        }
    }
}
