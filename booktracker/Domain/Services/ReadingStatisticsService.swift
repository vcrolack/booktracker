//
//  ReadingStatisticsService.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

struct ReadingStats {
    let totalPagesRead: Int
    let averagePagesPerHour: Double
    let currentStreakDays: Int
}

protocol ReadingStatisticsServiceProtocol {
    func calculateStats(from sessions: [ReadingSession]) -> ReadingStats
}

struct ReadingStatisticsService: ReadingStatisticsServiceProtocol {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    func calculateStats(from sessions: [ReadingSession]) -> ReadingStats {
        guard !sessions.isEmpty else {
            return ReadingStats(totalPagesRead: 0, averagePagesPerHour: 0.0, currentStreakDays: 0)
        }
        
        let totalPages = calculateTotalPages(sessions)
        let avgSpeed = calculateAverageSpeed(sessions, totalPages: totalPages)
        let streak = calculateCurrentSteak(sessions)
        
        return ReadingStats(
            totalPagesRead: totalPages,
            averagePagesPerHour: avgSpeed,
            currentStreakDays: streak
        )
    }
    
    private func calculateTotalPages(_ sessions: [ReadingSession]) -> Int {
        return sessions.reduce(0) {total, session in
            let pagesRead = session.endPage - (session.startPage ?? 0)
            return total + max(0, pagesRead)
        }
    }
    
    private func calculateAverageSpeed(_ sessions: [ReadingSession], totalPages: Int) -> Double {
        guard totalPages > 0 else { return 0.0 }
        
        let totalSeconds = sessions.reduce(0.0) { total, session in
            let duration = session.endTime.timeIntervalSince(session.startTime)
            return total + duration
        }
        
        let totalHours = totalSeconds / 3600.0
        guard totalHours > 0 else { return 0.0 }
        
        return Double(totalPages) / totalHours
    }
    
    private func calculateCurrentSteak(_ sessions: [ReadingSession]) -> Int {
        let sortedSessions = sessions.sorted { $0.endTime > $1.endTime }
        
        let uniqueDays = Set(sortedSessions.map { calendar.startOfDay(for: $0.endTime) })
        let sortedDays = Array(uniqueDays).sorted(by: >)
        
        guard let lastReadDay = sortedDays.first else { return 0 }
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if lastReadDay != today && lastReadDay != yesterday {
            return 0
        }
        
        var streak = 1
        var previousDay = lastReadDay
        
        for day in sortedDays.dropFirst() {
            let expectedPreviousDay = calendar.date(byAdding: .day, value: -1, to: previousDay)!
            
            if day == expectedPreviousDay {
                streak += 1
                previousDay = day
            } else {
                break
            }
        }
        return streak
    }
}
