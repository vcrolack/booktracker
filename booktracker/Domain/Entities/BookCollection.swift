//
//  Collection.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

enum BookCollectionDomainError: Error, Equatable {
    case bookAlreadyExists
    case bookNotFound
    case emptyName
}

struct BookCollection: Identifiable, Equatable, Codable {
    let id: UUID
    
    private(set) var name: String
    private(set) var description: String?
    private(set) var cover: String?
    
    private(set) var bookIds: Set<UUID>
    let createdAt: Date
    private(set) var updatedAt: Date = Date()
    
    init(id: UUID = UUID(), name: String, description: String? = nil, cover: String? = nil, bookIds: Set<UUID> = [], createdAt: Date = Date()) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            throw BookCollectionDomainError.emptyName
        }
        
        
        self.id = id
        self.name = name
        self.description = description
        self.cover = cover
        self.bookIds = bookIds
        self.createdAt = createdAt
    }
    
    mutating func addBook(id: UUID) throws {
        let (inserted, _) = bookIds.insert(id)
        guard inserted else {
            throw BookCollectionDomainError.bookAlreadyExists
        }
    }
    
    mutating func removeBook(id: UUID) throws {
        guard bookIds.remove(id) != nil else {
            throw BookCollectionDomainError.bookNotFound
        }
    }
    
    mutating func updateBookCollection(name: String?, description: String?, cover: String?) throws {
        if let newName = name {
            let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw BookCollectionDomainError.emptyName}
            self.name = trimmed
        }
        
        if let newDescription = description { self.description = newDescription }
        if let newCover = cover { self.cover = newCover }
        
        self.updatedAt = Date()
    }
}
