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
    
    // 1. Despertamos al Gerente General (Singleton) al iniciar la app.
    // Esto ejecuta el 'init()' secreto que conecta la base de datos.
    let container = DIContainer.shared

    var body: some Scene {
        WindowGroup {
            // 2. Aquí es donde pronto pasaremos los ViewModels
            ContentView()
        }.modelContainer(container.modelContainer)
        // 3. Opcional pero recomendado: Le inyectamos a SwiftUI el contenedor
        // que nuestro DIContainer ya configuró, por si alguna vista "tonta"
        // necesita el environment nativo de @Query en el futuro.
        
    }
}
