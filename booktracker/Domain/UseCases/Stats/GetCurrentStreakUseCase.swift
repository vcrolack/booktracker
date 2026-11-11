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
        // Sin límite de fecha: una racha puede cruzar el cambio de año.
        // Solo sesiones terminadas, la racha se calcula sobre endTime.
        let filter = ReadingSessionFilter(sortBy: .endTimeDescending, isActive: false)
        let sessions = try await fetchReadingSessionsUseCase.execute(filter: filter)
        
        let currentStreak = readingStatisticsService.calculateCurrentStreak(from: sessions)
        return currentStreak
    }
}
