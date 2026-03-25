//
//  FetchReadingGoalsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

protocol FetchReadingGoalsUseCaseProtocol {
    func execute() async throws -> [ReadingGoal]
}

final class FetchReadingGoalsUseCase: FetchReadingGoalsUseCaseProtocol {
    private let repository: ReadingGoalRepositoryProtocol
    
    init(repository: ReadingGoalRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [ReadingGoal] {
        return try await repository.fetchReadingGoals(criteria: ReadingGoalSearchField())
    }
}
