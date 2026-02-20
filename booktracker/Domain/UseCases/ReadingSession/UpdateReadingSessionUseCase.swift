//
//  UpdateReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol UpdateReadingSessionUseCaseProtocol {
    func execute(readingSessionId: UUID, command: UpdateReadingSessionCommand) async throws -> UUID
}

final class UpdateReadingSessionUseCase: UpdateReadingSessionUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    
    private let updateBookProgressUseCase: UpdateBookProgressUseCaseProtocol
    
    init(repository: ReadingSessionRepositoryProtocol, updateBookProgressUseCase: UpdateBookProgressUseCaseProtocol) {
        self.repository = repository
        self.updateBookProgressUseCase = updateBookProgressUseCase
    }
    
    func execute(readingSessionId: UUID, command: UpdateReadingSessionCommand) async throws -> UUID {
        guard var readingSession = try await repository.fetchSession(by: readingSessionId) else {
            throw RepositoryError.notFound
        }
        
        try readingSession.updateSession(
            newStartTime: command.startTime,
            newEndTime: command.endTime,
            newEndPage: command.endPage
        )
        
        if let newCurrentPage = command.endPage {
            try await updateBookProgressUseCase.execute(bookId: readingSession.bookId, newProgress: newCurrentPage)
        }
        
        try await repository.save(session: readingSession)
        
        return readingSession.id
    }
}

