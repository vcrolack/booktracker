//
//  RemoveBooksFromCollectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol RemoveBooksFromCollectionUseCaseProtocol {
    func execute(command: RemoveBooksFromCollectionCommand) async throws
}

final class RemoveBooksFromCollectionUseCase: RemoveBooksFromCollectionUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: RemoveBooksFromCollectionCommand) async throws {
        guard var bookCollection = try await repository.fetchCollection(by: command.collectionId) else {
            throw RepositoryError.notFound
        }
        
        for bookId in command.bookIds {
            do {
                try bookCollection.removeBook(id: bookId)
            } catch BookCollectionDomainError.bookNotFound {
                continue
            }
        }
        
        try await repository.save(bookCollection: bookCollection)
    }
}
