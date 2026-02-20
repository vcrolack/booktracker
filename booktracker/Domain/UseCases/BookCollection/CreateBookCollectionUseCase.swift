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
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: CreateBookCollectionCommand) async throws -> UUID {
        let newBookCollection = try BookCollection(
            name: command.name,
            description: command.description,
            cover: command.cover,
        )
        
        try await repository.save(bookCollection: newBookCollection)
        
        return newBookCollection.id
    }
}
