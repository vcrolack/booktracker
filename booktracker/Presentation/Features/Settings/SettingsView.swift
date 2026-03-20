//
//  SettingsView.swift
//  booktracker
//
//  Created by Victor rolack on 20-03-26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("app_theme") private var selectedTheme: AppTheme = .system
    @State private var notificationsEnabled = true


    var body: some View {
        NavigationStack {
            List {
                // 👤 SECCIÓN: PERFIL / CUENTA
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Vitocondrio")
                                .font(.headline)
                            Text("Miembro desde 2026")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: { Text("Cuenta") }

                // ⚙️ SECCIÓN: PREFERENCIAS
                Section {
                    Toggle("Notificaciones de lectura", isOn: $notificationsEnabled)
                    
                    Picker(selection: $selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.rawValue, systemImage: theme.icon)
                                .tag(theme)
                        }
                    } label: {
                        Label("Aspecto", systemImage: "paintbrush.fill")
                    }
                    .pickerStyle(.menu)
                } header: { Text("Personalización") }

                // 🗄️ SECCIÓN: GESTIÓN DE DATOS (Muy Senior 🛡️)
                Section {
                    NavigationLink(destination: Text("Lógica de Exportar")) {
                        Label("Exportar mi Biblioteca (JSON)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        // Acción de borrar cache de portadas
                    } label: {
                        Label("Limpiar caché de portadas", systemImage: "trash")
                    }
                } header: { Text("Datos y Almacenamiento") }
                
                // 📖 SECCIÓN: IDENTIDAD (Un toque de reverencia)
                Section {
                    NavigationLink(destination: Text("Créditos y Versión")) {
                        Label("Acerca de BookTracker", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "https://github.com/vcrolack")!) {
                        Label("Código Fuente", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                } header: { Text("Información") }
            }
            .navigationTitle("Ajustes")
        }
    }
}

#Preview {
    SettingsView()
}
