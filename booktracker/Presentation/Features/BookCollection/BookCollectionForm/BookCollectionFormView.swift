//
//  BookCollectionForm.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import SwiftUI

struct BookCollectionFormView: View {
    @State var viewModel: BookCollectionFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        CoverPickerView(imageData: $viewModel.selectedImageData)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Portada de la colección")
                } footer: {
                    Text("Elige una foto que represente tu colección de libros")
                }
                
                Section("Detalles") {
                    TextField("Nombre (ej. Favoritos 2024", text: $viewModel.name)
                        .autocorrectionDisabled()
                        
                    TextField("Descripción (opcional)", text: $viewModel.description)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle(viewModel.name.isEmpty ? "Nueva colección" : viewModel.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        viewModel.save()
                    }
                    .bold()
                    disabled(viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil},
            set: { _ in viewModel.errorMessage = nil })
        ) {
            Button("Entendido", role: .cancel) {}
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
    }
}

#Preview {
    BookCollectionFormView(viewModel: DIContainer.shared.makeBookCollectionFormViewModel())
}
