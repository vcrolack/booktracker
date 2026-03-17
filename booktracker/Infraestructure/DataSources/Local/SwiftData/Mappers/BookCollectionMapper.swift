//
//  BookCollectionMapper.swift
//  booktracker
//
//  Created by Victor rolack on 16-03-26.
//

enum BookCollectionMapper {
    static func toDataModel(from domain: BookCollection) -> BookCollectionSD {
        return BookCollectionSD(
            id: domain.id,
            name: domain.name,
            collectionDescription: domain.description,
            cover: domain.cover,
            bookIds: domain.bookIds,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt,
        )
    }
    
    static func toDomain(from sdModel: BookCollectionSD) -> BookCollection {
        return BookCollection(
            reconstituting: sdModel.id,
            name: sdModel.name,
            description: sdModel.collectionDescription,
            cover: sdModel.cover,
            bookIds: sdModel.bookIds,
            createdAt: sdModel.createdAt,
            updatedAt: sdModel.updatedAt
        )
    }
}
