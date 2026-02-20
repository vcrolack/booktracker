//
//  DeleteReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol DeleteReadingSessionUseCaseProtocol {
    func execute(readingSessionId: UUID) async throws
}

final class DeleteReadingSessionUseCase: DeleteReadingSessionUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    
    private let updateBookProgressUseCase: UpdateBookProgressUseCaseProtocol
    
    init(repository: ReadingSessionRepositoryProtocol, updateBookProgressUseCase: UpdateBookProgressUseCaseProtocol) {
        self.repository = repository
        self.updateBookProgressUseCase = updateBookProgressUseCase
    }
    
    func execute(readingSessionId: UUID) async throws {
        guard let sessionToDelete = try await repository.fetchSession(by: readingSessionId) else {
            return
        }
        
        let bookId = sessionToDelete.bookId
        
        try await repository.delete(sessionId: readingSessionId)
        
        let remainingSessions = try await repository.fetchSessions(for: bookId)
        
        let recalculatedCurrentPage = remainingSessions.map { $0.endPage }.max() ?? 0
        
        try await updateBookProgressUseCase.execute(bookId: bookId, newProgress: recalculatedCurrentPage)
        
    }
}
