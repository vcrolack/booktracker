//
//  StartReadingBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol StartReadingBookUseCaseProtocol {
    func execute(bookId: UUID) async throws
}

final class StartReadingBookUseCase: StartReadingBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws {
        guard var book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        try book.startReading(at: Date())
        
        try await repository.save(book: book)
    }
}
