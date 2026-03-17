//
//  BookCollectionSD.swift
//  booktracker
//
//  Created by Victor rolack on 16-03-26.
//
import Foundation
import SwiftData

@Model
final class BookCollectionSD {
    @Attribute(.unique) var id: UUID
    
    var name: String
    var collectionDescription: String?
    var cover: String?
    var bookIds: Set<UUID>
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID,
        name: String,
        collectionDescription: String? = nil,
        cover: String? = nil,
        bookIds: Set<UUID>,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.collectionDescription = collectionDescription
        self.cover = cover
        self.bookIds = bookIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
