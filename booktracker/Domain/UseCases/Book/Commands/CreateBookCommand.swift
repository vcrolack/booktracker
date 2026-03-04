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
    let status: BookStatus
    
    let isbn: String?
    let coverUrl: String?
    let editorial: String?
    let genre: String?
    let overview: String?
    let currentPage: Int?
}
