//
//  UpdateBookProgresUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol UpdateBookProgressUseCaseProtocol {
    func execute(bookId: UUID, newProgress currentPage: Int) async throws
}

final class UpdateBookProgressUseCase: UpdateBookProgressUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID, newProgress currentPage: Int) async throws {
        guard var book = try await repository.fetchBook(by: bookId) else {
            throw RepositoryError.notFound
        }
        
        if currentPage == book.currentPage {
            return
        }
        
        try book.updateMetadata(currentPage: currentPage)
        
        try await repository.save(book: book)
    }
}
