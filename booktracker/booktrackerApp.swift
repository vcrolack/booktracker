//
//  booktrackerApp.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import SwiftUI
import SwiftData
// Ya no necesitamos importar SwiftData aquí arriba,
// ¡porque el DIContainer se encarga de todo!

@main
struct booktrackerApp: App {
    
    let container = DIContainer.shared
    @State private var sessionManager = DIContainer.shared.globalSessionManager

    var body: some Scene {
        WindowGroup {
            // 🐈 El RootView ahora es el portero oficial
            RootView()
                .environment(sessionManager) // Inyectamos el manager para toda la app
        }
        .modelContainer(container.modelContainer) // SwiftData disponible globalmente
    }
}
