//
//  AddBookView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: AddBookViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                // SECCIÓN 1: Información principal
                Section(header: Text("Información del libro")) {
                    TextField("Título", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Autor", text: $viewModel.author)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Cantidad de páginas", text: $viewModel.pages)
                        .keyboardType(.numberPad)
                }
                
                // SECCIÓN 2: Metadatos
                Section(header: Text("Detalles"), footer: Text("Opcional: Pega la url de una imagen para una portada.")) {
                    Picker("Estado", selection: $viewModel.status) {
                        ForEach(BookStatus.allCases, id: \.self) { status in
                            Text(status.uiLabel).tag(status)
                        }
                    }
                    
                    TextField("URL de portada", text: $viewModel.coverUrl)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                // Sección 3: Manejo de errores
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .foregroundColor(.red)
                        .font(.footnote)
                    }
                }
            }
            .navigationTitle("Nuevo libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        Task {
                            let success = await viewModel.saveBook()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .bold()
                    .disabled(viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ZStack {
                        Color(UIColor.systemBackground).opacity(0.8)
                            .ignoresSafeArea()
                        ProgressView("Guardando en tu biblioteca...")
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                }
            }
        }
    }
}

#Preview {
    AddBookView(viewModel: DIContainer.shared.makeAddBookViewModel())
}
