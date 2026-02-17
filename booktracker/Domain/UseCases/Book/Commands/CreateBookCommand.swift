//
//  CreateBookCommand.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

struct CreateBookCommand {
    let title: String
    let author: String
    let pages: Int
    let ownership: Ownership
    let isbn: String?
}
