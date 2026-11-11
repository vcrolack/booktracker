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

    private(set) var pausedDuration: TimeInterval = 0
    private(set) var pausedAt: Date?

    var isActive: Bool {
        endTime == nil
    }

    var isPaused: Bool {
        pausedAt != nil
    }

    var durationInSeconds: TimeInterval {
        duration(at: Date())
    }

    /// Tiempo efectivamente leído hasta `date`, descontando las pausas.
    func duration(at date: Date) -> TimeInterval {
        let end = endTime ?? date
        let currentPause = pausedAt.map { end.timeIntervalSince($0) } ?? 0
        return max(0, end.timeIntervalSince(startTime) - pausedDuration - currentPause)
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
        endPage: Int?,
        pausedDuration: TimeInterval = 0,
        pausedAt: Date? = nil
    ) {
        self.id = id
        self.bookId = bookId
        self.startTime = startTime
        self.endTime = endTime
        self.startPage = startPage
        self.endPage = endPage
        self.pausedDuration = pausedDuration
        self.pausedAt = pausedAt
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

        if let pausedAt {
            self.pausedDuration += max(0, end.timeIntervalSince(pausedAt))
            self.pausedAt = nil
        }

        self.endTime = end
        self.endPage = page
    }

    mutating func pause(at date: Date = Date()) throws {
        guard isActive, pausedAt == nil else { return }

        guard date >= startTime else {
            throw ReadingSessionDomainError.invalidDateRange
        }

        self.pausedAt = date
    }

    mutating func resume(at date: Date = Date()) throws {
        guard isActive, let pausedAt else { return }

        guard date >= pausedAt else {
            throw ReadingSessionDomainError.invalidDateRange
        }

        self.pausedDuration += date.timeIntervalSince(pausedAt)
        self.pausedAt = nil
    }
}

