//
//  ReadingSessionRepositoryImpl.swift
//  booktracker
//
//  Created by Victor rolack on 10-03-26.
//

import Foundation

final class ReadingSessionRepositoryImpl: ReadingSessionRepositoryProtocol {
    private let localDataSource: ReadingSessionLocalDataSourceProtocol
    
    init(localDataSource: ReadingSessionLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }
    
    func save(session: ReadingSession) async throws {
        return try localDataSource.save(session: session)
    }
    
    func fetchSession(by id: UUID) async throws -> ReadingSession? {
        return try localDataSource.fetchReadingSession(by: id)
    }
    
    func fetchSessions(matching filter: ReadingSessionFilter?) async throws -> [ReadingSession] {
        return try localDataSource.fetchReadingSessions(matching: filter)
    }
    
    func delete(sessionId: UUID) async throws {
        return try localDataSource.deleteReadingSession(by: sessionId)
    }
    
    func deleteAll(for bookId: UUID) async throws {
        return try localDataSource.deleteAllReadingSessions(for: bookId)
    }
}
