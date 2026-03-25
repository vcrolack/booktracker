//
//  BTCarouselCardView.swift
//  booktracker
//
//  Created by Victor rolack on 16-03-26.
//

import SwiftUI

struct BTCarouselCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
            BTCardView {
                VStack(spacing: 8) {
                    TabView {
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    // 🚀 Activamos los dots con estilo de página
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .padding(-12)
            }
            .aspectRatio(1, contentMode: .fit)
        }
}

#Preview {
    ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // 1. Probando el Carrusel de Stats
                BTCarouselCardView {
                    BTInfoLabelView(value: "12", label: "Leídos", color: .green)
                    BTInfoLabelView(value: "5", label: "Pendientes", color: .blue)
                    BTInfoLabelView(value: "2", label: "Abandonados", color: .red)
                }
                .frame(width: 120, height: 120) // El tamaño que tendrá en el dashboard
                
                Text("Desliza la tarjeta para ver los estados")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
}
