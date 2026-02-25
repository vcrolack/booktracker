//
//  AcquireForReadingUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 25-02-26.
//

import Foundation

protocol AcquireBookForReadingUseCaseProtocol {
    func execute(bookId: UUID, newOwnership: Ownership) async throws
}

final class AcquireBookForReadingUseCase: AcquireBookForReadingUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID, newOwnership: Ownership) async throws {
        guard var book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        try book.acquireForReading(newOwnership: newOwnership)
        
        try await repository.save(book: book)
    }
}
