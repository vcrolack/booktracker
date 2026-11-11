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

        // Una sesión en curso todavía no movió el progreso del libro: borrarla (cancelar) no debe tocarlo.
        guard !sessionToDelete.isActive else { return }

        let remainingSessions = try await repository.fetchSessions(matching: ReadingSessionFilter(bookId: bookId))

        // La página donde empezó la sesión borrada es el piso: conserva el progreso previo
        // aunque no haya otras sesiones (libro creado con página inicial o editado a mano).
        let candidatePages = remainingSessions.compactMap { $0.endPage } + [sessionToDelete.startPage].compactMap { $0 }
        let recalculatedCurrentPage = candidatePages.max() ?? 0

        try await updateBookProgressUseCase.execute(bookId: bookId, newProgress: recalculatedCurrentPage)
        
    }
}
