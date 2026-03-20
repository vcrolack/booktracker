//
//  BookCollectionFormViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class BookCollectionFormViewModel {
    var name: String = ""
    var description: String = ""
    var selectedImageData: Data? = nil
    var currentImage: UIImage? = nil
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var shouldDismiss: Bool = false
    
    private let createBookCollectionUseCase: CreateBookCollectionUseCaseProtocol
    private let updateBookCollectionUseCase: UpdateBookCollectionUseCaseProtocol
    private let imageProcessor: ImageProcessorService
    
    let collectionToEdit: BookCollection?
    
    init(
        createBookCollectionUseCase: CreateBookCollectionUseCaseProtocol, 
        collectionToEdit: BookCollection? = nil,
        updateBookCollectionUseCase: UpdateBookCollectionUseCaseProtocol,
        imageProcessor: ImageProcessorService
    ) {
        self.createBookCollectionUseCase = createBookCollectionUseCase
        self.collectionToEdit = collectionToEdit
        self.updateBookCollectionUseCase = updateBookCollectionUseCase
        self.imageProcessor = imageProcessor
        
        if let collection = collectionToEdit {
            self.setupEditMode(with: collection)
        }
        
        if let collection = collectionToEdit {
            self.name = collection.name
            self.description = collection.description ?? ""
            
            // Cargamos los bytes del disco para que el CoverPickerView los muestre
            if let fileName = collection.cover {
                // Necesitamos un método en el imageProcessor que devuelva Data? o cargar el UIImage y convertirlo
                if let uiImage = imageProcessor.loadImage(fileName: fileName, folderName: "CollectionCovers") {
                    self.selectedImageData = uiImage.jpegData(compressionQuality: 0.8)
                }
            }
        }
    }
    
    func save() {
        guard validate() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if let oldCollection = collectionToEdit {
                    if let fileName = oldCollection.cover {
                        self.currentImage = imageProcessor.loadImage(
                            fileName: fileName,
                            folderName: "CollectionCovers"
                        )
                    }
                    let command = UpdateBookCollectionCommand(
                        bookCollectionId: oldCollection.id,
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: description.isEmpty ? nil : description,
                        cover: selectedImageData
                    )
                    _ = try await updateBookCollectionUseCase.execute(command: command)
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
            isLoading = false
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
