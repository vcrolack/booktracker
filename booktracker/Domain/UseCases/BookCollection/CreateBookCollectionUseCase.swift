//
//  CreateCollectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol CreateBookCollectionUseCaseProtocol {
    func execute(command: CreateBookCollectionCommand) async throws -> UUID
}

final class CreateBookCollectionUseCase: CreateBookCollectionUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    private let imageProcessor: ImageProcessorService
    
    init(repository: BookCollectionRepositoryProtocol, imageProcessor: ImageProcessorService) {
        self.repository = repository
        self.imageProcessor = imageProcessor
    }
    
    func execute(command: CreateBookCollectionCommand) async throws -> UUID {
        let id = UUID()
        var savedFileName: String? = nil
        
        if let data = command.cover {
            let fileName = "col_\(id.uuidString).jpg"
            savedFileName = imageProcessor.saveImage(data: data, fileName: fileName, folderName: "CollectionCovers")
        }
        
        let newBookCollection = try BookCollection(
            id: id,
            name: command.name,
            description: command.description,
            cover: savedFileName
        )
        
        try await repository.save(bookCollection: newBookCollection)
        
        return newBookCollection.id
    }
}
