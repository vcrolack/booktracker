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
        let stats = readingStatisticsService.calculateStats(from: <#T##[ReadingSession]#>)
    }
}
