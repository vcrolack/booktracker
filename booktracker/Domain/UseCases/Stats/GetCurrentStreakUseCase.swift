//
//  GetCurrentStreakUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 27-03-26.
//

import Foundation

protocol GetCurrentStreakUseCaseProtocol: Sendable {
    func execute() async throws -> Int
}

final class GetCurrentStreakUseCase: GetCurrentStreakUseCaseProtocol {
    private let fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    private let readingStatisticsService: ReadingStatisticsService
    
    init(readingStatisticsService: ReadingStatisticsService, fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol) {
        self.readingStatisticsService = readingStatisticsService
        self.fetchReadingSessionsUseCase = fetchReadingSessionsUseCase
    }
    
    func execute() async throws -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: .now)
        
        guard let startOfYear = calendar.date(from: components) else {
            throw ReadingSessionDomainError.invalidDateRange
        }
        
        let filter = ReadingSessionFilter(fromDate: startOfYear, toDate: .now, sortBy: .endTimeDescending)
        let sessions = try await fetchReadingSessionsUseCase.execute(filter: filter)
        print("[GET CURRENT STREAK USE CASE] sessions: \(sessions)\n")
        
        let currentStreak = readingStatisticsService.calculateCurrentStreak(from: sessions)
        return currentStreak
    }
}
