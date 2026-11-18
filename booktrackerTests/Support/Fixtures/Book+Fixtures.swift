//
//  Book+Fixtures.swift
//  booktracker
//
//  Created by Victor rolack on 12-11-26.
//

import Foundation
@testable import booktracker

extension Book {
    static func fixture(
        id: UUID = UUID(),
        title: String = "Dune",
        author: String = "Frank Herbert",
        pages: Int = 600,
        currentPage: Int? = nil,
        ownership: Ownership = .owner,
        status: BookStatus = .wishlist,
        createdAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) throws -> Book {
        try Book(
            id: id,
            title: title,
            author: author,
            pages: pages,
            currentPage: currentPage,
            ownership: ownership,
            status: status,
            createdAt: createdAt
        )
    }
}
