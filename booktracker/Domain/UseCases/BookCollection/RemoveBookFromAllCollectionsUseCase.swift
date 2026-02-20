//
//  RemoveBookFromAllCollectionsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol RemoveBookFromAllCollectionsUseCaseProtocol {
    func execute(bookId: UUID) async throws
}

final class RemoveBookFromAllCollectionsUseCase: RemoveBookFromAllCollectionsUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws {
        try await repository.deleteBookFromAll(bookId: bookId)
    }
}
