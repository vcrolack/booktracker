//
//  ReadingGoalSDDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import Foundation
import SwiftData

protocol ReadingGoalLocalDataSourceProtocol {
    func save(goal: ReadingGoal) throws
    func fetchReadingGoal(by id: UUID) throws -> ReadingGoal?
    func fetchReadingGoals(criteria: ReadingGoalSearchField) throws -> [ReadingGoal]
    func deleteReadingGoal(by id: UUID) throws
}

final class ReadingGoalSDDataSource: ReadingGoalLocalDataSourceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save(goal: ReadingGoal) throws {
        do {
            let readingGoalId = goal.id
            
            var descriptor = FetchDescriptor<ReadingGoalSD>(predicate: #Predicate { $0.id == readingGoalId })
            descriptor.fetchLimit = 1
            
            if let existingGoal = try context.fetch(descriptor).first {
                existingGoal.year = goal.year
                existingGoal.targetBooks = goal.targetBooks
                existingGoal.targetMinutesPerDay = goal.targetMinutesPerDay
            } else {
                let newGoal = ReadingGoalMapper.toDataModel(from: goal)
                context.insert(newGoal)
            }
            
            try context.save()
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
            
            guard let goalSD = try context.fetch(descriptor).first else {
                return nil
            }
            
            return ReadingGoalMapper.toDomain(from: goalSD)
        } catch {
            throw DataSourceError.fetchFailed("[Reading Goal SD] Goal not found")
        }
    }
    
    func fetchReadingGoals(criteria: ReadingGoalSearchField) throws -> [ReadingGoal] {
        let targetYear = criteria.year
        let targetId = criteria.id
        
        let predicate = #Predicate<ReadingGoalSD> { goal in
            (targetYear == nil || goal.year == targetYear)
            && (targetId == nil || goal.id == targetId)
        }
        
        let descriptor = FetchDescriptor<ReadingGoalSD>(predicate: predicate)
        
        do {
            let fetchedModels = try context.fetch(descriptor)
            return fetchedModels.map { ReadingGoalMapper.toDomain(from: $0) }
        } catch {
            throw DataSourceError.fetchFailed("[Reading Goal SD] Goals not found")
        }
    }
    
    func deleteReadingGoal(by id: UUID) throws {
        do {
            let readingGoalId = id
            let descriptor = FetchDescriptor<ReadingGoalSD>(predicate: #Predicate { $0.id == readingGoalId} )
            
            if let readingGoal = try context.fetch(descriptor).first {
                context.delete(readingGoal)
                try context.save()
            }
        } catch {
            throw DataSourceError.deleteFailed("[Reading Goal SD] Goal \(id) could not delete")
        }
    }
}
