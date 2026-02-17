//
//  FinishReadingBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol FinishReadingBookUseCaseProtocol {
    func execute(bookId: UUID) async throws
}

final class FinishReadingBookUseCase: FinishReadingBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws {
        guard var book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        try book.finishReading(at: Date())
        
        try await repository.save(book: book)
    }
}
