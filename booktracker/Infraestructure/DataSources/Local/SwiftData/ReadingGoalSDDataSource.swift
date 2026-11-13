//
//  ReadingGoalSDDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation
import SwiftData

protocol ReadingGoalLocalDataSourceProtocol: Sendable {
    func save(goal: ReadingGoal) async throws
    func fetchReadingGoal(by id: UUID) async throws -> ReadingGoal?
    func fetchReadingGoals(criteria: ReadingGoalSearchField) async throws -> [ReadingGoal]
    func deleteReadingGoal(by id: UUID) async throws
}

@ModelActor
actor ReadingGoalSDDataSource: ReadingGoalLocalDataSourceProtocol {
    func save(goal: ReadingGoal) throws {
        do {
            let readingGoalId = goal.id
            
            var descriptor = FetchDescriptor<ReadingGoalSD>(predicate: #Predicate { $0.id == readingGoalId })
            descriptor.fetchLimit = 1
            
            if let existingGoal = try modelContext.fetch(descriptor).first {
                existingGoal.year = goal.year
                existingGoal.targetBooks = goal.targetBooks
                existingGoal.targetMinutesPerDay = goal.targetMinutesPerDay
            } else {
                let newGoal = ReadingGoalMapper.toDataModel(from: goal)
                modelContext.insert(newGoal)
            }
            
            try modelContext.save()
        } catch {
            throw DataSourceError.saveFailed(error.localizedDescription)
        }
    }
    
    func fetchReadingGoal(by id: UUID) throws -> ReadingGoal? {
        do {
            let readingGoalId = id
            var descriptor = FetchDescriptor<ReadingGoalSD>(
                predicate: #Predicate { $0.id == readingGoalId }
            )
            
            descriptor.fetchLimit = 1
            
            guard let goalSD = try modelContext.fetch(descriptor).first else {
                return nil
            }
            
            return ReadingGoalMapper.toDomain(from: goalSD)
        } catch {
            throw DataSourceError.fetchFailed("[Reading Goal SD] Goal not found")
        }
    }
    
    func fetchReadingGoals(criteria: ReadingGoalSearchField) throws -> [ReadingGoal] {
        let predicate: Predicate<ReadingGoalSD>
        
        switch (criteria.year, criteria.id) {
        case let (year?, id?):
            predicate = #Predicate<ReadingGoalSD> { goal in
                goal.year == year && goal.id == id
            }
        case let (year?, nil):
            predicate = #Predicate<ReadingGoalSD> { goal in
                goal.year == year
            }
        case let (nil, id?):
            predicate = #Predicate<ReadingGoalSD> { goal in
                goal.id == id
            }
        case (nil, nil):
            predicate = #Predicate<ReadingGoalSD> { _ in true }
        }
        
        let descriptor = FetchDescriptor<ReadingGoalSD>(predicate: predicate)
        
        do {
            let fetchedModels = try modelContext.fetch(descriptor)
            return fetchedModels.map { ReadingGoalMapper.toDomain(from: $0) }
        } catch {
            throw DataSourceError.fetchFailed("[Reading Goal SD] Goals not found")
        }
    }
    
    func deleteReadingGoal(by id: UUID) throws {
        do {
            let readingGoalId = id
            let descriptor = FetchDescriptor<ReadingGoalSD>(predicate: #Predicate { $0.id == readingGoalId} )
            
            if let readingGoal = try modelContext.fetch(descriptor).first {
                modelContext.delete(readingGoal)
                try modelContext.save()
            }
        } catch {
            throw DataSourceError.deleteFailed("[Reading Goal SD] Goal \(id) could not delete")
        }
    }
}
