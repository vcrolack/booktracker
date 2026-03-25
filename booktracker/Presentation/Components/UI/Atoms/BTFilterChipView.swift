//
//  BTFilterChipView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BTFilterChipView: View {
    let title: String
    let isSelected: Bool
    var iconName: String? = nil
    var color: Color = .primary
    let action: () -> Void
    
    var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    // Renderizamos el ícono solo si nos pasaron uno
                    if let iconName = iconName {
                        Image(systemName: iconName)
                            .font(.system(size: 12, weight: .bold))
                    }
                    
                    Text(title.capitalized)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .medium)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // 🎨 Aquí usamos el color dinámico si está seleccionado
                .background(isSelected ? color : Color(UIColor.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected) // Una animación más "bouncy" y moderna
        }
}

#Preview {
    HStack {
        // Un chip genérico sin ícono
        BTFilterChipView(title: "Todos", isSelected: false) {}
        
        // Un chip semántico de tu dominio
        BTFilterChipView(
            title: "Leyendo",
            isSelected: true,
            iconName: "book.fill",
            color: .blue,
        ) {}
    }
    .padding()
}
