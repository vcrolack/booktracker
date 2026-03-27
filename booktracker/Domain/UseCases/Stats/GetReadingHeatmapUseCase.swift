//
//  GetReadingHeatmapUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation

struct DailyContribution: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Int
    
    var intensity: Int {
        switch minutes {
        case 0: return 0
        case 1...15: return 1
        case 16...30: return 2
        case 31...60: return 3
        default: return 4
        }
    }
}


protocol GetReadingHeatmapUseCaseProtocol: Sendable {
    func execute(year: Int) async throws -> [DailyContribution]
}

final class GetReadingHeatmapUseCase: GetReadingHeatmapUseCaseProtocol {
    private let fetchSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    private let calendar = Calendar.current
    
    init(fetchSessionsUseCase: FetchReadingSessionsUseCaseProtocol) {
        self.fetchSessionsUseCase = fetchSessionsUseCase
    }
    
    func execute(year: Int) async throws -> [DailyContribution] {
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        let filter = ReadingSessionFilter(fromDate: startOfYear, toDate: endOfYear)
        let sessions = try await fetchSessionsUseCase.execute(filter: filter)
        
        var minutesByDate: [Date: Int] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.startTime)
            let duration = Int(session.endTime?.timeIntervalSince(session.startTime) ?? 0) / 60
            minutesByDate[day, default: 0] += duration
        }
        
        var allDays: [DailyContribution] = []
        var currentDay = startOfYear
        
        while currentDay <= endOfYear {
            let minutes = minutesByDate[currentDay] ?? 0
            allDays.append(DailyContribution(date: currentDay, minutes: minutes))
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }
        
        return allDays
    }
}
