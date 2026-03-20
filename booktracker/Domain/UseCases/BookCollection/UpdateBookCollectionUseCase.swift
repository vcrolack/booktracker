//
//  UpdateBookCollectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol UpdateBookCollectionUseCaseProtocol {
    func execute(command: UpdateBookCollectionCommand) async throws -> UUID
}

final class UpdateBookCollectionUseCase: UpdateBookCollectionUseCaseProtocol {
    
    private let repository: BookCollectionRepositoryProtocol
    private let imageProcessor: ImageProcessorService
    
    init(repository: BookCollectionRepositoryProtocol, imageProcessor: ImageProcessorService) {
        self.repository = repository
        self.imageProcessor = imageProcessor
    }
    
    func execute(command: UpdateBookCollectionCommand) async throws -> UUID {
        guard var bookCollection = try await repository.fetchCollection(by: command.bookCollectionId) else {
            throw RepositoryError.notFound
        }
        
        var finalCoverPath = bookCollection.cover
        
        if let newImageData = command.cover {
            if let oldFileName = bookCollection.cover  {
                let result = imageProcessor.deleteImage(fileName: oldFileName, folderName: "CollectionCovers")
                if !result {
                    print("[BC update use case] Could not delete old image: \(oldFileName)")
                }
            }
            
            let newFileName = "col_\(bookCollection.id.uuidString).jpg"
            if let savedName = imageProcessor.saveImage(data: newImageData, fileName: newFileName, folderName: "CollectionCovers") {
                finalCoverPath = savedName
            }
        }
        
        try bookCollection.updateBookCollection(
            name: command.name,
            description: command.description,
            cover: finalCoverPath,
            bookIds: command.bookIds
        )
        
        try await repository.save(bookCollection: bookCollection)
        
        return bookCollection.id
    }
}
