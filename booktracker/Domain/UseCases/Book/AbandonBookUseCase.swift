//
//  AbandonBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol AbandonBookUseCaseProtocol {
    func execute(bookId: UUID, reason: String?) async throws
}

final class AbandonBookUseCase: AbandonBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID, reason: String? = nil) async throws {
        guard var book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        try book.abandon(reason: reason)
        
        try await repository.save(book: book)
    }
}
