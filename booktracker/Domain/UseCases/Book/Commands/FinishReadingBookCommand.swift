//
//  FinishReadingBookCommand.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation

struct FinishReadingBookCommand {
    let bookId: UUID
    var finishDate: Date = Date()
    var rating: Double? = nil
    var review: String? = nil
}
