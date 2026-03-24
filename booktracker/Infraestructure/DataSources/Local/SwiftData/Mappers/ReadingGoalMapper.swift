//
//  ReadingGoalMapper.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

enum ReadingGoalMapper {
    static func toDataModel(from domain: ReadingGoal) -> ReadingGoalSD {
        return ReadingGoalSD(
            id: domain.id,
            year: domain.year,
            targetBooks: domain.targetBooks,
            targetMinutesPerDay: domain.targetMinutesPerDay,
            createdAt: domain.createdAt
        )
    }
    
    static func toDomain(from sdModel: ReadingGoalSD) -> ReadingGoal {
        return ReadingGoal(
            reconstituting: sdModel.id,
            year: sdModel.year,
            targetBooks: sdModel.targetBooks,
            targetMinutesPerDay: sdModel.targetMinutesPerDay,
            createdAt: sdModel.createdAt
        )
    }
}
