//
//  FetchReadingSessionsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol FetchReadingSessionsUseCaseProtocol {
    func execute(filter: ReadingSessionFilter?) async throws -> [ReadingSession]
}

final class FetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    
    init(repository: ReadingSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(filter: ReadingSessionFilter? = nil) async throws -> [ReadingSession] {
        return try await repository.fetchSessions(matching: filter)
    }
}
