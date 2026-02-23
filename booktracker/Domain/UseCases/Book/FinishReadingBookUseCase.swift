//
//  FinishReadingBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol FinishReadingBookUseCaseProtocol {
    func execute(command: FinishReadingBookCommand) async throws
}

final class FinishReadingBookUseCase: FinishReadingBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: FinishReadingBookCommand) async throws {
        guard var book = try await repository.fetchBook(by: command.bookId) else {
            throw RepositoryError.notFound
        }
        
        try book.finishReading(at: Date(), rating: command.rating, review: command.review)
        
        try await repository.save(book: book)
    }
}
