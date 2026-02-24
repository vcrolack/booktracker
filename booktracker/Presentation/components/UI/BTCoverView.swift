//
//  BTCoverView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BTCoverView: View {
    let urlString: String?
    var width: CGFloat = 60
    var height: CGFloat = 90
    
    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = false
    
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ZStack {
                    Color(UIColor.secondarySystemBackground)
                    ProgressView()
                }
            } else {
                ZStack {
                    Color(UIColor.secondarySystemBackground)
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .task { await loadImage() }
    }
    
    private func loadImage() async {
        guard let urlString = urlString, !urlString.isEmpty else { return }
        
        isLoading = true
        self.uiImage = await ImageCacheManager.shared.getImage(from: urlString)
        isLoading = false
    }
}

// MARK: - 🎨 Previews
#Preview {
    // Usamos un VStack para acomodar bien las pruebas visuales
    VStack(spacing: 30) {
        
        Text("Pruebas de BTCoverView")
            .font(.headline)
        
        HStack(spacing: 20) {
            
            // 🧪 Prueba 1: URL nula (Debería mostrar el ícono del libro por defecto)
            VStack {
                BTCoverView(urlString: nil)
                Text("Sin URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 🧪 Prueba 2: URL real (Descarga de internet o lee del disco duro)
            // Usamos una portada de OpenLibrary (Neuromante de William Gibson)
            VStack {
                BTCoverView(urlString: "https://covers.openlibrary.org/b/id/8225261-M.jpg")
                Text("URL Válida")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 🧪 Prueba 3: Tamaño personalizado (Ideal para la vista de Detalle)
            VStack {
                BTCoverView(
                    urlString: "https://covers.openlibrary.org/b/id/8225261-M.jpg",
                    width: 100,
                    height: 150
                )
                Text("Tamaño Custom")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}
