//
//  AddBookView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BookFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: BookFormViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                // SECCIÓN 1: Información principal
                Section(header: Text("Información del libro")) {
                    TextField("Título", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
                    TextField("Autor", text: $viewModel.author)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
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
                    
                    Picker("Propiedad", selection: $viewModel.ownership) {
                        ForEach(Ownership.allCases, id: \.self) { ownership in
                            Text(ownership.uiLabel).tag(ownership)
                        }
                    }
                    
                    TextField("ISBN", text: $viewModel.isbn)
                        .keyboardType(.numberPad)
                    
                    TextField("Editorial", text: $viewModel.editorial)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
                    TextField("Género", text: $viewModel.genre)
                        .textInputAutocapitalization(.sentences)
                    
                    TextField("Página actual", text: $viewModel.currentPage)
                        .keyboardType(.numberPad)
                    
                    TextField("URL de portada", text: $viewModel.coverUrl)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Sinopsis"), footer: Text("Opcional: Agrega de qué va el libro.")) {
                    TextEditor(text: $viewModel.overview)
                        .frame(minWidth: 100)
                }
                
                // Sección 4: Manejo de errores
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
            .navigationTitle(viewModel.isEditing ? "Editar libro" : "Agregar libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Guardar" : "Agregar") {
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
            .alert("Error al guardar", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil},
                set: { if !$0 {viewModel.errorMessage = nil } }
                )
            ) {
                Button("Entendido", role: .cancel) {}
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    BookFormView(viewModel: DIContainer.shared.makeBookFormViewModel())
}
