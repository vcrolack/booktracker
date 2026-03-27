//
//  ContentView.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("app_theme") private var selectedTheme: AppTheme = .system
        
    var body: some View {
        MainTabView()
            .preferredColorScheme(selectedTheme.colorScheme)
            // Aquí puedes añadir más configuraciones globales de la UI real
    }
}

#Preview {
    ContentView()
}
