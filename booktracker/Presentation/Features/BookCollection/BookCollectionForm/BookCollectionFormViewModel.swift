//
//  BookCollectionFormViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class BookCollectionFormViewModel {
    var name: String = ""
    var description: String = ""
    var selectedImageData: Data? = nil
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var shouldDismiss: Bool = false
    
    private let createBookCollectionUseCase: CreateBookCollectionUseCaseProtocol
    
    private let collectionToEdit: BookCollection?
    
    init(createBookCollectionUseCase: CreateBookCollectionUseCaseProtocol, collectionToEdit: BookCollection? = nil) {
        self.createBookCollectionUseCase = createBookCollectionUseCase
        self.collectionToEdit = collectionToEdit
        
        if let collection = collectionToEdit {
            self.setupEditMode(with: collection)
        }
    }
    
    func save() {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let _ = collectionToEdit {
                    // TODO: Implementar lógica de edición
                } else {
                    let command = CreateBookCollectionCommand(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: description.isEmpty ? nil : description,
                        cover: selectedImageData
                    )
                    
                    _ = try await createBookCollectionUseCase.execute(command: command)
                }
                
                self.shouldDismiss = true
            } catch {
                self.errorMessage = "Ocurrió un error al guardar la colección"
                print("[BC FORM VIEW MODEL] Error saving book collection: \(error)")
            }
        }
    }
    
    private func validate() -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "El nombre no debe estar vacío"
            return false
        }
        return true
    }
    
    private func setupEditMode(with collection: BookCollection) {
        self.name = collection.name
        self.description = collection.description ?? ""
        // TODO: Add image and book ids
    }
}
