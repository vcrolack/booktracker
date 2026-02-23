//
//  DeleteBookCollectionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

protocol DeleteBookCollectionUseCaseProtocol {
    func execute(bookCollectionId: UUID) async throws
}

final class DeleteBookCollectionUseCase: DeleteBookCollectionUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookCollectionId: UUID) async throws {
        try await repository.delete(bookCollection: bookCollectionId)
    }
}
