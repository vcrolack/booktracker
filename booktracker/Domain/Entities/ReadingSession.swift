//
//  ReadingSession.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

enum ReadingSessionDomainError: Error, Equatable {
    case notFound
    case invalidDateRange
    case invalidPageProgression
}

struct ReadingSession: Identifiable, Codable, Equatable {
    let id: UUID
    let bookId: UUID
    
    private(set) var startTime: Date
    private(set) var endTime: Date?
    private(set) var startPage: Int?
    private(set) var endPage: Int?
    
    var isActive: Bool {
        endTime == nil
    }
    
    var durationInSeconds: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }
    
    init(
        id: UUID = UUID(),
        bookId: UUID,
        startTime: Date = Date(),
        endTime: Date? = nil,
        startPage: Int? = nil,
        endPage: Int? = nil,
    ) throws {
            if let end = endTime {
                guard  end >= startTime else {
                    throw ReadingSessionDomainError.invalidDateRange
                }
            }
            
            if let endP = endPage {
                guard endP >= (startPage ?? 0) else {
                    throw ReadingSessionDomainError.invalidPageProgression
                }
            }

            self.id = id
            self.bookId = bookId
            self.startTime = startTime
            self.endTime = endTime
            self.startPage = startPage
            self.endPage = endPage
        }
    
    init(
        reconstituting id: UUID,
        bookId: UUID,
        startTime: Date,
        endTime: Date?,
        startPage: Int?,
        endPage: Int?
    ) {
        self.id = id
        self.bookId = bookId
        self.startTime = startTime
        self.endTime = endTime
        self.startPage = startPage
        self.endPage = endPage
        
    }
    
    mutating func updateSession(newStartTime: Date? = nil, newEndTime: Date? = nil, newEndPage: Int? = nil) throws {
        let tentativeStart = newStartTime ?? self.startTime
        let tentativeEnd = newEndTime ?? self.endTime
        
        if let tentativeEnd {
            guard tentativeEnd >= tentativeStart else {
                throw ReadingSessionDomainError.invalidDateRange
            }
        }
        
        if let startP = self.startPage, let tentativeEndPage = newEndPage {
            guard tentativeEndPage >= startP else {
                throw ReadingSessionDomainError.invalidPageProgression
            }
        }
        
        if let start = newStartTime { self.startTime = start }
        if let end = newEndTime { self.endTime = end }
        if let page = newEndPage { self.endPage = page }
    }
    
    mutating func finishSession(at end: Date = Date(), inPage page: Int) throws {
        guard end >= startTime else {
            throw ReadingSessionDomainError.invalidPageProgression
        }
        
        guard page >= (startPage ?? 0) else {
            throw ReadingSessionDomainError.invalidPageProgression
        }
        
        self.endTime = end
        self.endPage = page
    }
}

