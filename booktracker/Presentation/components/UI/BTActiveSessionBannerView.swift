//
//  BTActiveSessionBannerView.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import SwiftUI

struct BTActiveSessionBannerView: View {
    let book: Book
    let session: ReadingSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            // 🚀 1. HStack puro, sin fondo ni sombra
            HStack(spacing: 16) {
                // 📚 Mini Portada con altura controlada
                BTCoverView(urlString: book.coverUrl, width: 20, height: 30)
                    .shadow(radius: 2, y: 1) // Sombra más sutil
                
                // 📝 Info de la sesión
                VStack(alignment: .leading, spacing: 2) { // Espaciado más compacto
                    Text("Lectura en curso")
                        .font(.caption2) // Un toque más pequeño
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .textCase(.uppercase)
                    
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // ⏱️ Animación de ecualizador azul
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            }
            // 🚀 2. Padding interno más compacto
            .padding(.horizontal, 16)
            .padding(.vertical, 8) // Padding vertical mínimo
            // 🚀 3. Altura fija para el contenido para asegurar que no se corte
            .frame(height: 50)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let mockBook = try? Book(
        id: UUID(),
        title: "Neuromante",
        author: "William Gibson",
        pages: 350,
        currentPage: 120,
        ownership: .owner,
        status: .finalized,
        coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg"
    )
    
    let sessionMock = try? ReadingSession(
        bookId: UUID(),
        startTime: Date(),
        endTime: Calendar.current.date(byAdding: .minute, value: 120, to: Date()),
        startPage: 12,
        endPage: 35
    )
    
    BTActiveSessionBannerView(book: mockBook!, session: sessionMock!, onTap: {})
}
