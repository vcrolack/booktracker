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
    
    init(
        id: UUID,
         bookId: UUID,
         startTime: Date,
         endTime: Date? = nil,
         startPage: Int? = nil,
         endPage: Int? = nil
    ) {
        self.id = id
        self.bookId = bookId
        self.startTime = startTime
        self.endTime = endTime
        self.startPage = startPage
        self.endPage = endPage
    }
}
