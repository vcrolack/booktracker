//
//  BTErrorState.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BTErrorState: View {
    let errorMessage: String
    let retryAction: () -> Void
    let buttonLabel: String = "Reintentar"
    
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Hubo un problema")
                .font(.headline)
            Text(errorMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(buttonLabel) {
                Task { retryAction() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    // 3. En el preview, le pasamos un closure vacío {} para que compile
    BTErrorState(
        errorMessage: "No se pudo conectar a la base de datos de SQLite. Verifica los permisos."
    ) {
        print("Botón de reintentar presionado en el Preview")
    }
}
