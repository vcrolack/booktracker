//
//  CreateReadingGoal.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

enum CreateReadingGoalError: Error, Equatable {
    case goalAlreadyExistsForYear
}

protocol CreateReadingGoalUseCaseProtocol {
    func execute(command: CreateReadingGoalCommand) async throws -> UUID
}

final class CreateReadingGoalUseCase: CreateReadingGoalUseCaseProtocol {
    private let repository: ReadingGoalRepository
    
    init(repository: ReadingGoalRepository) {
        self.repository = repository
    }
    
    func execute(command: CreateReadingGoalCommand) async throws -> UUID {
        guard let existingGoal = try await repository.fetchReadingGoal(for: ReadingGoalSearchField(year: command.year)) else {
            throw CreateReadingGoalError.goalAlreadyExistsForYear
        }
        
        let newGoal = try ReadingGoal(
            year: command.year,
            targetBooks: command.targetBooks,
            targetMinutesPerDay: command.targetMinutesPerDay
        )
        
        try await repository.save(readingGoal: newGoal)
    
        return newGoal.id
    }
}
