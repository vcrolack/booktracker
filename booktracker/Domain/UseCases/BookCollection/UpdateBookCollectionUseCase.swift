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
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: UpdateBookCollectionCommand) async throws -> UUID {
        guard var bookCollection = try await repository.fetchCollection(by: command.bookCollectionId) else {
            throw RepositoryError.notFound
        }
        
        try bookCollection.updateBookCollection(name: command.name, description: command.description, cover: command.cover)
        
        try await repository.save(bookCollection: bookCollection)
        
        return bookCollection.id
    }
}
