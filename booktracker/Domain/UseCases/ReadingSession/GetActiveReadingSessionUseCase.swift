//
//  GetActiveReadingSessionUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import Foundation

protocol GetActiveReadingSessionUseCaseProtocol {
    func execute() async throws -> ReadingSession?
}

final class GetActiveReadingSessionUseCase: GetActiveReadingSessionUseCaseProtocol {
    private let repository: ReadingSessionRepositoryProtocol
    
    init(repository: ReadingSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> ReadingSession? {
        let activeSessions = try await repository.fetchSessions(matching: ReadingSessionFilter(isActive: true))
        
        guard !activeSessions.isEmpty else { return nil }
        
        if activeSessions.count == 1 {
            return activeSessions.first
        }
        
        print("[READING SESSION GUARD] Found \(activeSessions.count) active sessions. Cleaning up...")
        
        let sortedSessions = activeSessions.sorted { $0.startTime > $1.startTime }
        
        let trueActiveSession = sortedSessions.first!
        
        let ghostSessions = sortedSessions.dropFirst()
        for ghost in ghostSessions {
            try await repository.delete(sessionId: ghost.id)
            print("[READING SESSION GUARD] Gosth session \(ghost.id) deleted")
        }
        
        return trueActiveSession
    }
}
