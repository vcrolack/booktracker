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
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        pages: Int,
        currentPage: Int? = nil,
        ownership: Ownership,
        status: BookStatus = .wishlist,
        coverUrl: String? = nil,
        isbn: String? = nil,
        editorial: String? = nil,
        genre: String? = nil,
        overview: String? = nil,
        createdAt: Date = Date()
    ) throws {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        self.pages = pages
        self.currentPage = currentPage ?? 0
        self.ownership = ownership
        self.status = status
        self.coverUrl = coverUrl
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.isbn = isbn
        self.editorial = editorial
        self.genre = genre
        self.overview = overview
        
        try validateInvariants()
    }
    
    init(
        reconstituting id: UUID,
        title: String,
        author: String,
        overview: String?,
        pages: Int,
        currentPage: Int,
        editorial: String?,
        isbn: String?,
        ownership: Ownership,
        status: BookStatus,
        coverUrl: String?,
        genre: String?,
        globalRating: String?,
        userRating: Double?,
        userReview: String?,
        startDate: Date?,
        endDate: Date?,
        abandonReason: String?,
        createdAt: Date,
        updatedAt: Date,
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.overview = overview
        self.pages = pages
        self.currentPage = currentPage
        self.editorial = editorial
        self.isbn = isbn
        self.ownership = ownership
        self.status = status
        self.coverUrl = coverUrl
        self.genre = genre
        self.globalRating = globalRating
        self.userRating = userRating
        self.userReview = userReview
        self.startDate = startDate
        self.endDate = endDate
        self.abandonReason = abandonReason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    mutating func startReading(at date: Date = Date()) throws {
        guard status == .toRead else {
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
        genre: String? = nil,
        overview: String? = nil,
        at date: Date = Date()
    ) throws {
        var draft = self

        if let title { draft.title = title.trimmingCharacters(in: .whitespacesAndNewlines)}
        if let author { draft.author = author.trimmingCharacters(in: .whitespacesAndNewlines)}
        if let pages { draft.pages = pages }
        if let currentPage { draft.currentPage = currentPage }
        if let editorial { draft.editorial = editorial }
        if let isbn { draft.isbn = isbn }
        if let ownership { draft.ownership = ownership }
        if let coverUrl { draft.coverUrl = coverUrl }
        if let genre { draft.genre = genre }
        if let overview { draft.overview = overview }
        
        try draft.validateInvariants()
        
        draft.updatedAt = date
        self = draft
    }
    
    mutating func acquireForReading(newOwnership: Ownership, at date: Date = Date()) throws {
        guard status == .wishlist else {
            throw BookDomainError.invalidStateTransition(from: status, to: .toRead)
        }
        
        self.status = .toRead
        self.ownership = newOwnership
        self.updatedAt = date
    }
    
    private func validateInvariants() throws {
        guard !title.isEmpty, !author.isEmpty else { throw BookDomainError.emptyTitleOrAuthor }
        guard pages > 0 else {
            throw BookDomainError.invalidPageCount
        }
        guard (0...pages).contains(currentPage) else {
            throw BookDomainError.invalidCurrentPage(currentPage: currentPage, totalPages: pages)
        }
    }
}
