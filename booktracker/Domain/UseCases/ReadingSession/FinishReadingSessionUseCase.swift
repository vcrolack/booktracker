//
//  FinishReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 09-03-26.
//

import Foundation

protocol FinishReadingSessionUseCaseProtocol {
    func execute(id: UUID, endPage: Int, endTime: Date) async throws
}

final class FinishReadingSessionUseCase: FinishReadingSessionUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    private let updateBookProgressUseCase: UpdateBookProgressUseCaseProtocol
    
    init(
        repository: ReadingSessionRepositoryProtocol,
        updatedBookProgressUseCase: UpdateBookProgressUseCaseProtocol,
    ) {
        self.repository = repository
        self.updateBookProgressUseCase = updatedBookProgressUseCase
    }
    
    func execute(id: UUID, endPage: Int, endTime: Date) async throws {
        guard var session = try await repository.fetchSession(by: id) else {
            throw ReadingSessionDomainError.notFound
        }
        
        try session.finishSession(at: endTime, inPage: endPage)
        
        try await repository.save(session: session)
        
        // 4. 🚀 Espacio para efectos secundarios:
                // - Detener Live Activity / Dynamic Island
                // - Actualizar progreso total del libro
        
        try await updateBookProgressUseCase.execute(bookId: session.bookId, newProgress: endPage)
    }
}
