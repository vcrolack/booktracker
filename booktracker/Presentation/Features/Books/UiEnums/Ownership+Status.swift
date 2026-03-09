//
//  Ownership+Status.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

extension Ownership {
    var uiLabel: String {
        switch self {
        case .notOwner: return "Sin ejemplar"
        case .owner: return "En mi colección"
        case .borrowed: return "Prestado"
        }
    }
}
