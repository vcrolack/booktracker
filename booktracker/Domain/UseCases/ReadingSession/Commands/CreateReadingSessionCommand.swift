//
//  CreateReadingSessionCommand.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

struct CreateReadingSessionCommand {
    let bookId: UUID
    let startTime: Date
    let endTime: Date
    let startPage: Int?
    let endPage: Int
}
