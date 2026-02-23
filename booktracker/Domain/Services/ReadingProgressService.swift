//
//  ReadingProgressService.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

struct ReadingProgressStats {
    let targetBooks: Int
    let booksReadThisYear: Int
    let bookCompletionsPercentage: Double
    
    let targetMinutesPerDay: Int?
    let minutesReadToday: Int
    let isDailyGoalMet: Bool
}

protocol ReadingProgressServiceProtocol {
    func calculateProgress(
        goal: ReadingGoal,
        books: [Book],
        sessions: [ReadingSession],
        currentDate: Date
    ) -> ReadingProgressStats
}

struct ReadingProgressService: ReadingProgressServiceProtocol {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    func calculateProgress(goal: ReadingGoal, books: [Book], sessions: [ReadingSession], currentDate: Date) -> ReadingProgressStats {
        // 1. Book calculate
        let booksReadThisYear = books.filter { book in
            guard book.status == .finalized, let finishedAt = book.endDate else { return false }
            
            return calendar.component(.year, from: finishedAt) == goal.year
        }.count
        
        let percentage = goal.targetBooks > 0 ? (Double(booksReadThisYear) / Double(goal.targetBooks)) * 100.0 : 0.0
        
        // 2. Minutes per day calculate (today)
        let todaySessions = sessions.filter { session in
            calendar.isDate(session.endTime, inSameDayAs: currentDate)
        }
        
        let totalSecondsToday = todaySessions.reduce(0.0) { total, session in
            total + session.endTime.timeIntervalSince(session.startTime)
        }
        let minutesReadToday = Int(totalSecondsToday / 60.0)
        
        // 3. Check goals
        let isDailyMet: Bool
        if let targetMinutes = goal.targetMinutesPerDay {
            isDailyMet = minutesReadToday >= targetMinutes
        } else {
            isDailyMet = false
        }
        
        return ReadingProgressStats(
            targetBooks: goal.targetBooks,
            booksReadThisYear: booksReadThisYear,
            bookCompletionsPercentage: min(percentage, 100.0),
            targetMinutesPerDay: goal.targetMinutesPerDay,
            minutesReadToday: minutesReadToday,
            isDailyGoalMet: isDailyMet
        )
    }
    
}

