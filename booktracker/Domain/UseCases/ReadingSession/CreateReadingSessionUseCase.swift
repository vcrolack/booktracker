//
//  CreateReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol CreateReadingSessionUseCaseProtocol {
    func execute(command: CreateReadingSessionCommand) async throws -> UUID
}

final class CreateReadingSessionUseCase: CreateReadingSessionUseCaseProtocol {
    private let readingSessionRepository: ReadingSessionRepositoryProtocol
    private let bookRepository: BookRepositoryProtocol
    
    init(repository: ReadingSessionRepositoryProtocol, bookRepository: BookRepositoryProtocol) {
        self.readingSessionRepository = repository
        self.bookRepository = bookRepository
    }
    
    func execute(command: CreateReadingSessionCommand) async throws -> UUID {
        guard let book = try await bookRepository.fetchBook(by: command.bookId) else {
            throw RepositoryError.notFound
        }
        
        let newSession = try ReadingSession(
            bookId: command.bookId,
            startTime: command.startTime,
            startPage: command.startPage,
        )
        
        try await bookRepository.save(book: book)
        try await readingSessionRepository.save(session: newSession)
        
        return newSession.id
    }
}
