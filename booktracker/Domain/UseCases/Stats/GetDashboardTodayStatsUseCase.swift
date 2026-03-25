//
//  GetDashboardStatsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation

protocol GetDashboardTodayStatsUseCaseProtocol {
    func execute(year: Int) async throws -> ReadingProgressStats
}

final class GetDashboardTodayStatsUseCase: GetDashboardTodayStatsUseCaseProtocol {
    private let readingGoalRepository: ReadingGoalRepositoryProtocol
    private let progressService: ReadingProgressService
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    private let fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol
    
    init(
        readingGoalRepository: ReadingGoalRepositoryProtocol,
        progressService: ReadingProgressService,
        fetchBooksUseCase: FetchBooksUseCaseProtocol,
        fetchReadingSessionsUseCase: FetchReadingSessionsUseCaseProtocol,
    ) {
        self.readingGoalRepository = readingGoalRepository
        self.progressService = progressService
        self.fetchBooksUseCase = fetchBooksUseCase
        self.fetchReadingSessionsUseCase = fetchReadingSessionsUseCase
    }
    
    func execute(year: Int) async throws -> ReadingProgressStats {
        let criteria = ReadingGoalSearchField(year: year)
        let goals = try await readingGoalRepository.fetchReadingGoals(criteria: criteria)
        
        guard let goal = goals.first else {
            throw DashboardError.goalNotFound(year: year)
        }
        
        let bookFilter = BookFilter(status: .finalized, finishYear: year)
        let finalizedBooks = try await fetchBooksUseCase.execute(filter: bookFilter)
        
        let sessionFilter = ReadingSessionFilter(fromDate: .now)
        let todaySessions = try await fetchReadingSessionsUseCase.execute(filter: sessionFilter)
        
        return progressService.calculateProgress(
            goal: goal,
            books: finalizedBooks,
            sessions: todaySessions,
            currentDate: .now
        )
    }
}

enum DashboardError: Error {
    case goalNotFound(year: Int)
    case dataInconsistency
}
