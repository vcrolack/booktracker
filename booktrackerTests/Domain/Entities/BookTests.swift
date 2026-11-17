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
    
    @Test("Unless instructed, current page starts with zero value and status wishlist")
    func defaultValues() throws {
        let book = try Book(title: "Dune", author: "Frank Herbert", pages: 600, ownership: .owner)
        
        #expect(book.currentPage == 0)
        #expect(book.status == .wishlist)
        #expect(book.startDate == nil)
        #expect(book.userRating == nil)
    }
}

@Suite("Book - Errors")
struct BookErrorsTests {
    @Test("Throw an error if the title is empty")
    func emptyTitleThrows() {
        #expect(throws: BookDomainError.emptyTitleOrAuthor) {
            try Book(title: "", author: "Frank Herbert", pages: 600, ownership: .owner)
        }
    }
    
    @Test("Throw an error if currentPage exceed total pages")
    func currentPageGreaterThanPagesThrow() {
        #expect(throws: BookDomainError.invalidCurrentPage(currentPage: 601, totalPages: 600)) {
            try Book(title: "Dune", author: "Frank Herbert", pages: 600, currentPage: 601, ownership: .owner)
        }
    }
    
    @Test("Throw an error if title is empty or if has only empty spaces", arguments: ["", "  ", "\n", "\t  \n"])
    func blankTitleThrows(title: String) {
        #expect(throws: BookDomainError.emptyTitleOrAuthor) {
            try Book(title: title, author: "Frank Herbert", pages: 600, ownership: .owner)
        }
    }
    
    @Test("Throw an error if pages is zero or negative", arguments: [0, -1, -100])
    func invalidPagesThrow(pages: Int) {
        #expect(throws: BookDomainError.invalidPageCount) {
            try Book(title: "Dune", author: "Frank Herbert", pages: pages, ownership: .owner)
        }
    }
}

@Suite("Book - Edge cases")
struct BookEdgeTests {
    @Test("When current page is equal to pages not throws")
    func currentPageEqualPages() throws {
        let book = try Book(title: "Dune", author: "Frank Herbert", pages: 600, currentPage: 600, ownership: .owner)
        
        #expect(book.currentPage == book.pages)
    }
    
    @Test("Minimum value (1) to pages is valid")
    func minimumValueToPages() throws {
        let book = try Book(title: "Dune", author: "Frank Herbert", pages: 1, ownership: .owner)
        
        #expect(book.pages == 1)
    }
}

@Suite("Book - startReading")
struct BookStartReadingTests {
    let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    
    @Test("From toRead to reading and startDate registered")
    func startsReadingFromToRead() throws {
        // Arrange
        var book = try Book.fixture(status: .toRead)
        
        // Act
        try book.startReading(at: fixedDate)
        
        // Assert
        #expect(book.status == .reading)
        #expect(book.startDate == fixedDate)
        #expect(book.updatedAt == fixedDate)
    }
    
    @Test("From any state different to toRead throw an error", arguments: BookStatus.allCases.filter { $0 != .toRead })
    func cannotStartReadingFromInvalidStatus(status: BookStatus) throws {
        var book = try Book.fixture(status: status)
        
        #expect(throws: BookDomainError.invalidStateTransition(from: status, to: .reading)) {
            try book.startReading(at: fixedDate)
        }
        
        #expect(book.status == status)
        #expect(book.startDate == nil)
    }
}

@Suite("Book - finishReading")
struct BookFinishReadingTests {
    let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    
    @Test("Upon completion, currentPage is equal to pages")
    func finishingSetsCurrentPageToTotal() throws {
        var book = try Book.fixture(pages: 300, currentPage: 120, status: .reading)
        
        try book.finishReading(at: fixedDate)
        
        #expect(book.status == .finalized)
        #expect(book.currentPage == 300)
        #expect(book.endDate == fixedDate)
    }
    
    @Test("With valid rate, save it next the rewiew")
    func saveRateWithReview() throws {
        var book = try Book.fixture(pages: 300, currentPage: 120, status: .reading)
        let rate = 4.5
        let review = "It was a good book"
        
        try book.finishReading(at: fixedDate, rating: rate, review: review)
        
        #expect(book.status == .finalized)
        #expect(book.userRating == rate)
        #expect(book.userReview == review)
    }
    
    @Test("With invalid rating throw an error", arguments: [0, 0.9, 5.1, -1])
    func invalidRating(rating: Double) throws {
        var book = try Book.fixture(currentPage: 120, status: .reading)
        
        #expect(throws: BookDomainError.invalidRatingValue) {
            try book.finishReading(at: fixedDate, rating: rating)
        }
        
        #expect(book.currentPage == 120)
    }
    
    @Test("1 and 5 value for rating are valid", arguments: [1.0, 5.0])
    func extremeRatingValues(rating: Double) throws {
        var book = try Book.fixture(currentPage: 120, status: .reading)
        
        try book.finishReading(at: fixedDate, rating: rating)
        
        #expect(book.status == .finalized)
        #expect(book.userRating == rating)
    }
}

@Suite("Book - abandon")
struct BookAbandonTests {
    let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    
    @Test("Transition to abandon with a valid reason and endDate")
    func transtionToAbandon() throws{
        var book = try Book.fixture(status: .reading)
        let reason = "Book sucks"
        
        try book.abandon(reason: reason, at: fixedDate)
        
        #expect(book.abandonReason == reason)
        #expect(book.endDate == fixedDate)
        #expect(book.status == .abandoned)
    }
    
    @Test("From any other state, abandon throw an error", arguments: BookStatus.allCases.filter { $0 != .reading })
    func cannotAbandonFromInvalidStatus(status: BookStatus) throws {
        var book = try Book.fixture(status: status)
        
        #expect(throws: BookDomainError.invalidStateTransition(from: status, to: .abandoned)) {
            try book.abandon(reason: "x", at: fixedDate)
        }
        
        #expect(book.status == status)
        #expect(book.abandonReason == nil)
        #expect(book.endDate == nil)
    }
}

@Suite("Book - acquireForReading")
struct BookAcquireForReading {
    @Test("From whislist to toRead and ownership update")
    func fromWishlistToToRead() throws {
        var book = try Book.fixture(ownership: .notOwner, status: .wishlist)
        
        try book.acquireForReading(newOwnership: .owner)
        
        #expect(book.status == .toRead)
        #expect(book.ownership == .owner)
    }
    
    @Test("From any state different wishlist, fails", arguments: BookStatus.allCases.filter { $0 != .wishlist })
    func cannotAcquireFromInvalidStatus(status: BookStatus) throws {
        var book = try Book.fixture(ownership: .notOwner, status: status)

        #expect(throws: BookDomainError.invalidStateTransition(from: status, to: .toRead)) {
            try book.acquireForReading(newOwnership: .owner)
        }

        #expect(book.status == status)
        #expect(book.ownership == .notOwner)
    }
}

@Suite("Book - pdateMetadata")
struct BookUpdateMetadata {
    let fixedDate = Date(timeIntervalSince1970: 1_700_000)
    
    @Test("If fails a validation, none field will be updated")
    func failedUpdateLeavesBookUntouched() throws {
        var book = try Book.fixture(title: "Dune", author: "Frank Herbert")
        
        #expect(throws: BookDomainError.emptyTitleOrAuthor) {
            try book.updateMetadata(title: "Nuevo título", author: "     ")
        }
        
        #expect(book.title == "Dune")
        #expect(book.author == "Frank Herbert")
    }
    
    @Test("Decrease pages below currentPage throw an error and not modifies the book")
    func reducingPagesBelowCurrentPageThrows() throws {
        var book = try Book.fixture(pages: 300, currentPage: 250)
        
        #expect(throws: BookDomainError.invalidCurrentPage(currentPage: 250, totalPages: 200)) {
            try book.updateMetadata(pages: 200)
        }
        
        #expect(book.pages == 300)
        #expect(book.currentPage == 250)
    }
    
    @Test("Reducing pages with a valid currentPage works")
    func reducingPagesWithValidCurrentPageSucceeds() throws {
        var book = try Book.fixture(pages: 300, currentPage: 250)
        
        try book.updateMetadata(pages: 200,  currentPage: 150)
        
        #expect(book.pages == 200)
        #expect(book.currentPage == 150)
    }
}
