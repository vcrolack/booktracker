//
//  ReadingSessionRepositoryProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

struct ReadingSessionFilter {
    var bookId: UUID? = nil
    var fromDate: Date? = nil
    var toDate: Date? = nil
    
    var sortBy: SortOption? = .startTimeDescending
    var isActive: Bool? = nil
    
    enum SortOption {
        case startTimeAscending
        case startTimeDescending
        case endPageDescending
        case endPageAscending
        case endTimeDescending
        case endTimeAscending
    }
}

protocol ReadingSessionRepositoryProtocol {
    func fetchSession(by id: UUID) async throws -> ReadingSession?
    func fetchSessions(matching filter: ReadingSessionFilter?) async throws -> [ReadingSession]
    
    func save(session: ReadingSession) async throws
    
    func delete(sessionId: UUID) async throws
    func deleteAll(for bookId: UUID) async throws
}
