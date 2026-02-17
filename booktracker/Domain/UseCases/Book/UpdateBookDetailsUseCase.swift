//
//  UpdateBookDetailsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol UpdateBookDetailsUseCaseProtocol {
    func execute(command: UpdateBookCommand) async throws -> UUID
}

final class UpdateBookDetailsUseCase: UpdateBookDetailsUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: UpdateBookCommand) async throws -> UUID {
        guard var book = try await repository.fetchBook(by: command.bookId) else {
            throw RepositoryError.notFound
        }
        
        try book.updateMetadata(title: command.title,
                                author: command.author,
                                pages: command.pages,
                                editorial: command.editorial,
                                isbn: command.isbn,
                                ownership: command.ownership,
                                coverUrl: command.coverURL,
                                genre: command.genre
        )
        
        try await repository.save(book: book)
        
        return book.id
    }
}
