//
//  BTEmptyStateView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BTEmptyStateView: View {
    let title: String
    let iconName: String
    let description: String?
    
    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: iconName,
            description: description.map { Text($0) }
        )
    }
}

#Preview {
    VStack {
        // 🧪 Caso 1: Estado vacío completo (Ej. Lista de libros vacía)
        BTEmptyStateView(
            title: "No hay libros",
            iconName: "books.vertical",
            description: "Tu biblioteca está vacía o ningún libro coincide con tu búsqueda."
        )
        
        Divider()
        
        // 🧪 Caso 2: Estado vacío simple (Ej. Sin descripción)
        BTEmptyStateView(
            title: "Búsqueda sin resultados",
            iconName: "magnifyingglass",
            description: nil
        )
    }
}
