//
//  CreateBookUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol CreateBookUseCaseProtocol {
    func execute(command: CreateBookCommand) async throws -> UUID
}

final class CreateBookUseCase: CreateBookUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(command: CreateBookCommand) async throws -> UUID {
        // TODO: validar si el libro ya existe
        var newBook = try Book(title: command.title, author: command.author, pages: command.pages, ownership: command.ownership, status: .wishlist)
        
        newBook.isbn = command.isbn
        
        try await repository.save(book: newBook)
        
        return newBook.id
    }
}
