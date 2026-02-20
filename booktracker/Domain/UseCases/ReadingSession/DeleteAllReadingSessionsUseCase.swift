//
//  DeleteAllReadingSessions.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol DeleteAllReadingSessionsUseCaseProtocol {
    func execute(bookId: UUID) async throws
}

final class DeleteAllReadingSessionsUseCase: DeleteAllReadingSessionsUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    
    init(repository: ReadingSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(bookId: UUID) async throws {
        try await repository.deleteAll(for: bookId)
    }
}
