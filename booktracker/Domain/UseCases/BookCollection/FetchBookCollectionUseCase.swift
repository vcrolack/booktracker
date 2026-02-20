//
//  FetchBookColectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol FetchBookCollectionUseCaseProtocol {
    func execute(bookCollectionId: UUID) async throws -> BookCollection
}

final class FetchBookCollectionUseCase: FetchBookCollectionUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookCollectionId: UUID) async throws -> BookCollection {
        guard let bookCollection = try await repository.fetchCollection(by: bookCollectionId) else {
            throw RepositoryError.notFound
        }
        
        return bookCollection
    }
}

