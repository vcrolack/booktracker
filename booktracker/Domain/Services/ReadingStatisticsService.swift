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
    func calculateCurrentStreak(from sessions: [ReadingSession]) -> Int
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
        let streak = calculateCurrentStreak(from: sessions)
        
        return ReadingStats(
            totalPagesRead: totalPages,
            averagePagesPerHour: avgSpeed,
            currentStreakDays: streak
        )
    }
    
    private func calculateTotalPages(_ sessions: [ReadingSession]) -> Int {
        return sessions.reduce(0) { total, session in
            guard let endPage = session.endPage else { return total }
            let pagesRead = endPage - (session.startPage ?? 0)
            return total + max(0, pagesRead)
        }
    }
    
    private func calculateAverageSpeed(_ sessions: [ReadingSession], totalPages: Int) -> Double {
        guard totalPages > 0 else { return 0.0 }
        
        let totalSeconds = sessions.reduce(0.0) { total, session in
            guard let endTime = session.endTime else { return total }
            let duration = endTime.timeIntervalSince(session.startTime)
            return total + duration
        }
        
        let totalHours = totalSeconds / 3600.0
        guard totalHours > 0 else { return 0.0 }
        
        return Double(totalPages) / totalHours
    }
    
    func calculateCurrentStreak(from sessions: [ReadingSession]) -> Int {
    // 1. Si no hay sesiones, no hay racha. 🛡️
        guard let firstSession = sessions.first,
              let firstEndTime = firstSession.endTime else { return 0 }

        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let firstDay = calendar.startOfDay(for: firstEndTime)

        // 2. Validación inicial: Si lo último no fue hoy ni ayer, racha es 0. 🛑
        if firstDay < yesterday { return 0 }

        var streak = 0
        var nextExpectedDay = firstDay // Empezamos buscando el día más reciente
        var lastDayCounted: Date? = nil

        // 3. El Bucle Maestro: O(k) con Early Exit ⚡
        for session in sessions {
            guard let endTime = session.endTime else { continue }
            let sessionDay = calendar.startOfDay(for: endTime)

            // Ignoramos sesiones múltiples en el mismo día
            if sessionDay == lastDayCounted { continue }

            if sessionDay == nextExpectedDay {
                // ¡Match! Aumentamos racha y buscamos el día anterior
                streak += 1
                lastDayCounted = sessionDay
                nextExpectedDay = calendar.date(byAdding: .day, value: -1, to: sessionDay)!
            } else if sessionDay < nextExpectedDay {
                // ¡Hueco encontrado! No hay necesidad de seguir iterando. 🏛️
                break
            }
        }

        return streak
    }
}
