//
//  GetMonthlyReadingActivityUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation

struct MonthlyEffort: Identifiable {
    var id: Int { month }
    let month: Int
    let totalMinutes: Int
    
    var monthName: String {
        Calendar.current.shortMonthSymbols[month - 1].capitalized
    }
}

protocol GetMonthlyEffortUseCaseProtocol {
    func execute(year: Int) async throws -> [MonthlyEffort]
}

final class GetMonthlyEffortUseCase: GetMonthlyEffortUseCaseProtocol {
    private let fetchSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    
    init(fetchSessionsUseCase: FetchReadingSessionsUseCaseProtocol) {
        self.fetchSessionsUseCase = fetchSessionsUseCase
    }
    
    func execute(year: Int) async throws -> [MonthlyEffort] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))
        
        let filter = ReadingSessionFilter(
            fromDate: startOfYear,
            toDate: endOfYear,
            sortBy: .startTimeAscending
        )
        
        let sessions = try await fetchSessionsUseCase.execute(filter: filter)
        
        var monthlyMinutes: [Int: Int] = (1...12).reduce(into: [:]) { $0[$1] = 0 }
        
        for session in sessions {
            if let endTime = session.endTime {
                let month = Calendar.current.component(.month, from: endTime)
                let durationMinutes = Int(endTime.timeIntervalSince(session.startTime) / 60)
                monthlyMinutes[month, default: 0] += durationMinutes
            }
        }
        
        return monthlyMinutes.keys.sorted().map { month in
            MonthlyEffort(month: month, totalMinutes: monthlyMinutes[month] ?? 0)
        }
    }
}

