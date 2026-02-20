//
//  ReadingSessionRepositoryProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

struct ReadingSessionFilter {
    var bookId: UUID?
    var fromDate: Date?
    var toDate: Date?
    
    var sortBy: SortOption? = .startTimeDescending
    
    enum SortOption {
        case startTimeAscending
        case startTimeDescending
        case endPageDescending
    }
}

protocol ReadingSessionRepositoryProtocol {
    func fetchSession(by id: UUID) async throws -> ReadingSession?
    func fetchSessions(matching filter: ReadingSessionFilter?) async throws -> [ReadingSession]
    
    func save(session: ReadingSession) async throws
    
    func delete(sessionId: UUID) async throws
    func deleteAll(for bookId: UUID) async throws
}
