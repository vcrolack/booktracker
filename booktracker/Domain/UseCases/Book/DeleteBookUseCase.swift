//
//  DeleteBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol DeleteBookUseCaseProtocol {
    func execute(bookId: UUID) async throws
}

final class DeleteBookUseCase: DeleteBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws {
        guard var book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        try await repository.delete(bookId: bookId)
    }
}
