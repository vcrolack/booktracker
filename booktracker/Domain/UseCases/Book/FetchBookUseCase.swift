//
//  FetchBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol FetchBookUseCaseProtocol {
    func execute(bookId: UUID) async throws -> Book
}

final class FetchBookUseCase: FetchBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws -> Book {
        guard let book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        return book
    }
}
