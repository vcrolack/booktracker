//
//  BookTests.swift
//  booktrackerTests
//
//  Created by Victor rolack on 12-11-26.
//

import Testing
import Foundation
@testable import booktracker

@Suite("Book - Initialization")
struct BookTests {

    @Test("Create a valid book with correct data")
    func createsValidBook() throws {
        // Arrange + Act
        let book = try Book(
            title: "Dune",
            author: "Frank Herbert",
            pages: 600,
            ownership: .owner
        )
        
        #expect(book.title == "Dune")
        #expect(book.author == "Frank Herbert")
        #expect(book.pages == 600)
        #expect(book.ownership == .owner)
    }
    
    @Test("Delete spaces at init and the end of title and author")
    func trimsTitleAndAuthor() throws {
        let book = try Book(
            title: "     Dune    \n",
            author: "\tFrank Herbert  ",
            pages: 600,
            ownership: .owner
        )
        
        #expect(book.title == "Dune")
        #expect(book.author == "Frank Herbert")
    }

}
