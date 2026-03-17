//
//  BTCardView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BTCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color(UIColor.secondarySystemBackground).ignoresSafeArea()
        
        VStack(spacing: 16) {
            // Ejemplo 1: Una tarjeta de libro
            BTCardView {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Neuromante").font(.headline)
                        Text("William Gibson").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("Leyendo").font(.caption).foregroundColor(.blue)
                }
            }
            
            // Ejemplo 2: ¡La misma tarjeta usada para algo totalmente distinto!
            BTCardView {
                HStack {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text("Meta anual: 12 Libros")
                }
            }
        }
        .padding()
    }
}
