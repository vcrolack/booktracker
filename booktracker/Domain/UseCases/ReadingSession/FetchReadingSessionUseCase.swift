//
//  FetchReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol FetchReadingSessionUseCaseProtocol {
    func execute(readingSessionId: UUID) async throws -> ReadingSession
}

final class FetchReadingSessionUseCase: FetchReadingSessionUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    
    init(repository: ReadingSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(readingSessionId: UUID) async throws -> ReadingSession {
        guard let readingSession = try await repository.fetchSession(by: readingSessionId) else {
            throw RepositoryError.notFound
        }
        
        return readingSession
    }
}
