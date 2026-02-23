//
//  UpdateReadingGoalUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

protocol UpdateReadingGoalUseCaseProtocol {
    func execute(command: UpdateReadingGoalCommand) async throws -> UUID
}

final class UpdateReadingGoalUseCase: UpdateReadingGoalUseCaseProtocol {
    private let repository: ReadingGoalRepository
    
    init(repository: ReadingGoalRepository) {
        self.repository = repository
    }
    
    func execute(command: UpdateReadingGoalCommand) async throws -> UUID {
        guard var goal = try await repository.fetchReadingGoal(for: ReadingGoalSearchField(id: command.goalId)) else {
            throw RepositoryError.notFound
        }
        
        try goal.updateGoals(newTargetBooks: command.targetBooks, newTargetMinutesPerDay: command.targetMinutesPerDay)
        
        try await repository.save(readingGoal: goal)
        
        return goal.id
    }
}
