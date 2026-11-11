//
//  ReadingSessionAttributes.swift
//  booktracker
//
//  Created by Victor rolack on 14-03-26.
//

import Foundation
import ActivityKit

nonisolated struct ReadingSessionAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        var isReading: Bool
        var currentSprintStartTime: Date?
        var accumulatedTime: TimeInterval

        /// Fecha desde la que un cronómetro que cuenta hacia arriba muestra el tiempo total
        /// (sprint actual + tiempo acumulado de sprints anteriores).
        var timerStartDate: Date {
            (currentSprintStartTime ?? .now).addingTimeInterval(-accumulatedTime)
        }

        /// Si está en pausa, el cronómetro se congela en el tiempo acumulado.
        var timerPauseDate: Date? {
            isReading ? nil : timerStartDate.addingTimeInterval(accumulatedTime)
        }
    }
    
    var bookTitle: String
    var author: String
    var bookId: UUID
}
