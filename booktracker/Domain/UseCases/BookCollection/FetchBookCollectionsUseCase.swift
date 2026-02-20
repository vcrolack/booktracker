//
//  FetchBookCollectionsUseCase.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

protocol FetchBookCollectionsUseCaseProtocol {
    func execute(filter: BookCollectionFilter?) async throws -> [BookCollection]
}

final class FetchBookCollectionsUseCase: FetchBookCollectionsUseCaseProtocol {
    private let repository: BookCollectionRepositoryProtocol
    
    init(repository: BookCollectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(filter: BookCollectionFilter? = nil) async throws -> [BookCollection] {
        return try await repository.fetchCollections(matching: filter)
    }
}
