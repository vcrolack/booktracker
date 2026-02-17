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
        guard var book = try await bookRepository.fetchBook(by: command.bookId) else {
            throw RepositoryError.notFound
        }
        
        let newSession = try ReadingSession(
            bookId: command.bookId,
            startTime: command.startTime,
            endTime: command.endTime,
            startPage: command.startPage,
            endPage: command.endPage
        )
        
        try book.updateMetadata(currentPage: command.endPage)
        
        try await bookRepository.save(book: book)
        try await readingSessionRepository.save(session: newSession)
        
        return newSession.id
    }
}
