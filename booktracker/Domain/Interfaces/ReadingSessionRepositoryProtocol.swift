//
//  ReadingSessionRepositoryProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

protocol ReadingSessionRepositoryProtocol {
    func fetchSession(by id: UUID) async throws -> ReadingSession?
    func fetchSessions(for bookId: UUID) async throws -> [ReadingSession]
    
    func save(session: ReadingSession) async throws
    
    func delete(sessionId: UUID) async throws
}
