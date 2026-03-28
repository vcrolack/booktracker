//
//  GetWeeklyReadingSessionsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 27-03-26.
//

import Foundation

protocol GetWeeklyReadingSessionsUseCaseProtocol: Sendable {
    func execute(for date: Date) async throws -> [ReadingSession]
}

final class GetWeeklyReadingSessionsUseCase: GetWeeklyReadingSessionsUseCaseProtocol {
    private let fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    private let calendar: Calendar
    
    init(calendar: Calendar = .current, fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol) {
        self.calendar = calendar
        self.fetchReadingSessionsUseCase = fetchReadingSessionsUseCase
    }
    
    func execute(for date: Date = Date()) async throws -> [ReadingSession] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        
        let startOfWeek = interval.start
        let endOfWeek = interval.end
        
        let filter = ReadingSessionFilter(fromDate: startOfWeek, toDate: endOfWeek)
        return try await fetchReadingSessionsUseCase.execute(filter: filter)
    }
}
