//
//  BookSD.swift
//  booktracker
//
//  Created by Victor rolack on 23-02-26.
//

import Foundation
import SwiftData

@Model
final class BookSD {
    @Attribute(.unique) var id: UUID
    
    var title: String
    var author: String
    var overview: String?
    var pages: Int
    var currentPage: Int
    var editorial: String?
    var isbn: String?
    
    var statusRawValue: String
    var ownershipRawValue: String
    
    var coverUrl: String?
    var genre: String?
    var globalRating: String?
    
    var userRating: Double?
    var userReview: String?
    var startDate: Date?
    var endDate: Date?
    var abandonReason: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID,
        title: String,
        author: String,
        overview: String? = nil,
        pages: Int,
        currentPage: Int,
        editorial: String? = nil,
        isbn: String? = nil,
        statusRawValue: String,
        ownershipRawValue: String,
        coverUrl: String? = nil,
        genre: String? = nil,
        globalRating: String? = nil,
        userRating: Double? = nil,
        userReview: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        abandonReason: String? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.overview = overview
        self.pages = pages
        self.currentPage = currentPage
        self.editorial = editorial
        self.isbn = isbn
        self.statusRawValue = statusRawValue
        self.ownershipRawValue = ownershipRawValue
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
    
}
