//
//  book.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

enum BookStatus: String, Equatable, CaseIterable, Codable {
    case wishlist
    case toRead
    case reading
    case finalized
    case abandoned
}

enum Ownership: String, Equatable, CaseIterable, Codable {
    case owner
    case notOwner
    case borrowed
}

enum BookDomainError: Error, Equatable {
    case invalidStateTransition(from: BookStatus, to: BookStatus)
    case cannotReviewUnfinishedBook
    case invalidRatingValue
    case emptyTitleOrAuthor
    case invalidPageCount
    case invalidCurrentPage(currentPage: Int, totalPages: Int)
}

struct Book: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var author: String
    var overview: String?
    var pages: Int
    var currentPage: Int
    var editorial: String?
    var isbn: String?
    var ownership: Ownership
    
    private(set) var status: BookStatus
    
    var coverUrl: String?
    var genre: String?
    var globalRating: String?
    
    // Datos dependientes del estado
    private(set) var userRating: Double?
    private(set) var userReview: String?
    private(set) var startDate: Date?
    private(set) var endDate: Date?
    private(set) var abandonReason: String?
    
    let createdAt: Date
    private(set) var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, author: String, pages: Int, currentPage: Int? = nil, ownership: Ownership, status: BookStatus = .wishlist) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedAuthor.isEmpty else {
            throw BookDomainError.emptyTitleOrAuthor
        }
        
        guard pages > 0 else {
            throw BookDomainError.invalidPageCount
        }
        
        let initialPage = currentPage ?? 0
        guard initialPage >= 0 && initialPage <= pages else {
            throw BookDomainError.invalidCurrentPage(currentPage: initialPage, totalPages: pages)
        }
        
        self.id = id
        self.title = trimmedTitle
        self.author = trimmedAuthor
        self.pages = pages
        self.currentPage = initialPage
        self.ownership = ownership
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    mutating func startReading(at date: Date = Date()) throws {
        guard status == .toRead || status == .wishlist else {
            throw BookDomainError.invalidStateTransition(from: status, to: .reading)
        }
        
        self.status = .reading
        self.startDate = date
        self.updatedAt = date
    }
    
    mutating func finishReading(at date: Date = Date(), rating: Double? = nil, review: String? = nil) throws {
        guard status == .reading else {
            throw BookDomainError.invalidStateTransition(from: status, to: .finalized)
        }
        
        if let rating = rating {
            guard (1...5).contains(rating) else {
                throw BookDomainError.invalidRatingValue
            }
            self.userRating = rating
        }
        
        self.status = .finalized
        self.endDate = date
        self.currentPage = self.pages
        self.userReview = review
        self.updatedAt = date
    }
    
    mutating func abandon(reason: String? = nil, at date: Date = Date()) throws {
        guard status == .reading else {
            throw BookDomainError.invalidStateTransition(from: status, to: .abandoned)
        }
        
        self.status = .abandoned
        self.abandonReason = reason
        self.endDate = date
        self.updatedAt = date
    }
    
    mutating func updateMetadata(
        title: String? = nil,
        author: String? = nil,
        pages: Int? = nil,
        currentPage: Int? = nil,
        editorial: String? = nil,
        isbn: String? = nil,
        ownership: Ownership? = nil,
        coverUrl: String? = nil,
        genre: String? = nil
    ) throws {
        if let newTitle = title {
            let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw BookDomainError.emptyTitleOrAuthor }
            self.title = trimmed
        }
        
        if let newAuthor = author {
            let trimmed = newAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw BookDomainError.emptyTitleOrAuthor }
            self.author = trimmed
        }
        
        if let newPages = pages {
            guard newPages > 0 else { throw BookDomainError.invalidPageCount }
            self.pages = newPages
        }
        
        if let newCurrentPage = currentPage {
            guard newCurrentPage >= 0 && newCurrentPage <= self.pages else {
                throw BookDomainError.invalidCurrentPage(currentPage: newCurrentPage, totalPages: self.pages)
            }
            self.currentPage = newCurrentPage
        }
        
        if let newEditorial = editorial { self.editorial = newEditorial }
        if let newIsbn = isbn { self.isbn = newIsbn }
        if let newOwnership = ownership { self.ownership = newOwnership }
        if let newCoverUrl = coverUrl { self.coverUrl = newCoverUrl }
        if let newGenre = genre { self.genre = newGenre }
        
        self.updatedAt = Date()
    }
    
}
