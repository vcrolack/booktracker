//
//  AddBookToCollectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol AddBookToCollectionUseCaseProtocol {
    func execute(command: AddBookToCollectionCommand) async throws
}

final class AddBookToCollectionUseCase: AddBookToCollectionUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: AddBookToCollectionCommand) async throws {
        guard var bookCollection = try await repository.fetchCollection(by: command.collectionId)  else {
            throw RepositoryError.notFound
        }
        
        for bookId in command.bookIds {
            do {
                try bookCollection.addBook(id: bookId)
            } catch BookCollectionDomainError.bookAlreadyExists {
                continue
            }
        }
        
        try await repository.save(bookCollection: bookCollection)
    }
}
