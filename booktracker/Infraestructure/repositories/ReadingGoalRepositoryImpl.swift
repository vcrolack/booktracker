//
//  ReadingGoalRepositoryImpl.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation

final class ReadingGoalRepositoryImpl: ReadingGoalRepositoryProtocol {
    private let localDataSource: ReadingGoalLocalDataSourceProtocol
    
    init(localDataSource: ReadingGoalLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }
    
    func save(goal: ReadingGoal) async throws {
        return try await localDataSource.save(goal: goal)
    }
    
    func fetchReadingGoal(by id: UUID) async throws -> ReadingGoal? {
        return try await localDataSource.fetchReadingGoal(by: id)
    }
    
    func fetchReadingGoals(criteria: ReadingGoalSearchField) async throws -> [ReadingGoal] {
        return try await localDataSource.fetchReadingGoals(criteria: criteria)
    }
    
    func delete(by id: UUID) async throws {
        return try await localDataSource.deleteReadingGoal(by: id)
    }
}
