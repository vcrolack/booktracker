//
//  UpdateBookCommand.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

struct UpdateBookCommand {
    let bookId: UUID
    var title: String?
    var author: String?
    var pages: Int?
    var editorial: String?
    var isbn: String?
    var ownership: Ownership?
    var coverURL: String?
    var genre: String?
}
