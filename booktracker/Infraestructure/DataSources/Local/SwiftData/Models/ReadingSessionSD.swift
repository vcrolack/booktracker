//
//  ReadingSessionSD.swift
//  booktracker
//
//  Created by Victor rolack on 09-03-26.
//

import Foundation
import SwiftData

@Model
final class ReadingSessionSD {
    @Attribute(.unique) var id: UUID
    var bookId: UUID
    
    var startTime: Date
    var endTime: Date?
    var startPage: Int?
    var endPage: Int?

    // Valores por defecto para que la migración ligera de SwiftData funcione con sesiones existentes
    var pausedDuration: TimeInterval = 0
    var pausedAt: Date?

    init(
        id: UUID,
         bookId: UUID,
         startTime: Date,
         endTime: Date? = nil,
         startPage: Int? = nil,
         endPage: Int? = nil,
         pausedDuration: TimeInterval = 0,
         pausedAt: Date? = nil
    ) {
        self.id = id
        self.bookId = bookId
        self.startTime = startTime
        self.endTime = endTime
        self.startPage = startPage
        self.endPage = endPage
        self.pausedDuration = pausedDuration
        self.pausedAt = pausedAt
    }
}
