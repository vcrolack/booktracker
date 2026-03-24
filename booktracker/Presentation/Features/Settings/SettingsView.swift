//
//  SettingsView.swift
//  booktracker
//
//  Created by Victor rolack on 20-03-26.
//

import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel
    @State private var showingEmojiPicker = false


    var body: some View {
        NavigationStack {
            List {
                account
                preferences
                dataAndStorage
                about
            }
            .navigationTitle("Ajustes")
        }
        .task { viewModel.calculateStorage() }
    }
    
    @ViewBuilder
    private var account: some View {
        Section {
            HStack(spacing: 15) {
                Button {
                    showingEmojiPicker = true
                } label: {
                    Text(viewModel.userAvatar)
                        .font(.system(size:40))
                        .frame(width: 70, height: 70)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Circle())
                        .overlay(
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.accentColor)
                                .background(Circle().fill(.background))
                                .offset(x: 25, y: 25)
                        )
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading) {
                    TextField("Nombre", text: $viewModel.userName)
                        .font(.headline)
                    Text("Miembro desde 2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .sheet(isPresented: $showingEmojiPicker) {
                BTEmojiPickerView(selectedEmoji: $viewModel.userAvatar, title: "Elije tu avatar")
            }
        } header: { Text("Cuenta") }
    }
    
    @ViewBuilder
    private var preferences: some View {
        Section {
            Toggle("Notificaciones de lectura", isOn: $viewModel.notificationsEnabled)
            
            Picker(selection: $viewModel.selectedTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.rawValue, systemImage: theme.icon)
                        .tag(theme)
                }
            } label: {
                Label("Aspecto", systemImage: "paintbrush.fill")
            }
            .pickerStyle(.menu)
        } header: { Text("Personalización") }
    }
    
    @ViewBuilder
    private var dataAndStorage: some View {
        // 🗄️ SECCIÓN: GESTIÓN DE DATOS (Muy Senior 🛡️)
        Section {
            LabeledContent("Memoria utilizada", value: viewModel.storageUsage ?? "Cargando...")
            NavigationLink(destination: Text("Lógica de Exportar")) {
                Label("Exportar mi Biblioteca (JSON)", systemImage: "square.and.arrow.up")
            }
        } header: { Text("Datos y Almacenamiento") }
    }
    
    @ViewBuilder
    private var about: some View {
        // 📖 SECCIÓN: IDENTIDAD (Un toque de reverencia)
        Section {
            NavigationLink(destination: AboutBookTracker()) {
                Label("Acerca de BookTracker", systemImage: "info.circle")
            }
            
            Link(destination: URL(string: "https://rolackdev.com")!) {
                Label("Acerca del creador", systemImage: "person.fill")
            }
            
            Link(destination: URL(string: "https://github.com/vcrolack")!) {
                Label("Código Fuente", systemImage: "chevron.left.forwardslash.chevron.right")
            }
        } header: { Text("Información") }
    }
}

#Preview {
    SettingsView(viewModel: DIContainer.shared.makeSettingsViewModel())
}
