//
//  UpdateReadingGoalCommand.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

struct UpdateReadingGoalCommand {
    let goalId: UUID
    var targetBooks: Int? = nil
    var targetMinutesPerDay: Int? = nil
}
