//
//  BookMapper.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation

enum BookMapper {
    static func toDataModel(from domain: Book) -> BookSD {
        return BookSD(
            id: domain.id,
            title: domain.title,
            author: domain.author,
            overview: domain.overview,
            pages: domain.pages,
            currentPage: domain.currentPage,
            editorial: domain.editorial,
            isbn: domain.isbn,
            statusRawValue: domain.status.rawValue,
            ownershipRawValue: domain.ownership.rawValue,
            coverUrl: domain.coverUrl,
            genre: domain.genre,
            globalRating: domain.globalRating,
            userRating: domain.userRating,
            userReview: domain.userReview,
            startDate: domain.startDate,
            endDate: domain.endDate,
            abandonReason: domain.abandonReason,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt,
        )
    }
    
    static func toDomain(from sdModel: BookSD) -> Book {
        let parsedOwnership = Ownership(rawValue: sdModel.ownershipRawValue) ?? .notOwner
        let parsedStatus = BookStatus(rawValue: sdModel.statusRawValue) ?? .wishlist
        
        let book = Book(
            reconstituting: sdModel.id,
            title: sdModel.title,
            author: sdModel.author,
            overview: sdModel.overview,
            pages: sdModel.pages,
            currentPage: sdModel.currentPage,
            editorial: sdModel.editorial,
            isbn: sdModel.isbn,
            ownership: parsedOwnership,
            status: parsedStatus,
            coverUrl: sdModel.coverUrl,
            genre: sdModel.genre,
            globalRating: sdModel.globalRating,
            userRating: sdModel.userRating,
            userReview: sdModel.userReview,
            startDate: sdModel.startDate,
            endDate: sdModel.endDate,
            abandonReason: sdModel.abandonReason,
            createdAt: sdModel.createdAt,
            updatedAt: sdModel.updatedAt
        )
        
        return book
    }
}
