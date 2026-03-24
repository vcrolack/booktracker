//
//  AboutBookTracker.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import SwiftUI

struct AboutBookTracker: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "book.fill") // Un icono grande de la app
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    
                    Text("BookTracker")
                        .font(.title.bold())
                    
                    Text("Versión 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section("Nuestra Misión") {
                Text("BookTracker nació de la necesidad de un espacio tranquilo y privado para gestionar nuestras lecturas. Sin algoritmos, sin anuncios, sin suscripciones. Solo tú y tu biblioteca.")
                    .font(.subheadline)
            }
            
            Section("Desarrollo") {
                LabeledContent("Creado por", value: "Victor Rolack")
                Link("Github", destination: URL(string: "https://github.com/vcrolack")!)
                Link("Contacto", destination: URL(string: "https://rolackdev.com/contact")!)
            }
            
            Section {
                Text("Soli Deo Gloria")
                    .font(.caption)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AboutBookTracker()
}
