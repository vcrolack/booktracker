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
        var newBook = try Book(title: command.title, author: command.author, pages: command.pages, ownership: command.ownership, status: command.status, coverUrl: command.coverUrl, isbn: command.isbn)
        
        switch command.status {
            case .reading:
                try newBook.startReading(at: Date()) // Suponiendo que tienes este método
            case .finalized:
                // Lo marcamos como finalizado al instante de crearlo
                try newBook.finishReading(at: Date(), rating: nil, review: nil)
            case .abandoned:
                try newBook.abandon(reason: nil) // Suponiendo que tienes este método
            default:
                break
        }
        
        try await repository.save(book: newBook)
        
        return newBook.id
    }
}
