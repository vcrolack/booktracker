//
//  FetchCurrentReadingGoalUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

protocol FetchCurrentReadingGoalUseCaseProtocol {
    func execute(forYear year: Int?) async throws -> ReadingGoal?
}

final class FetchCurrentReadingGoalUseCase: FetchCurrentReadingGoalUseCaseProtocol {
    private let repository: ReadingGoalRepository
    private let calendar: Calendar
    
    init(repository: ReadingGoalRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    func execute(forYear year: Int? = nil) async throws -> ReadingGoal? {
        let targetYear = year ?? calendar.component(.year, from: Date())
        
        return try await repository.fetchReadingGoal(for: ReadingGoalSearchField(year: targetYear))
    }
}
