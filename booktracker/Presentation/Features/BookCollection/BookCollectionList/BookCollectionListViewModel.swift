//
//  BookCollectionListViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 19-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class BookCollectionListViewModel {
    var bookCollections: [BookCollection] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var filteredCollections: [BookCollection] {
        if searchText.isEmpty {
            return bookCollections
        }
        
        return bookCollections.filter { collection in
            collection.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private let fetchBookCollectionsUseCase: FetchBookCollectionsUseCaseProtocol
    
    init(fetchBookCollectionsUseCase: FetchBookCollectionsUseCaseProtocol) {
        self.fetchBookCollectionsUseCase = fetchBookCollectionsUseCase
    }
    
    func fetchCollections() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.bookCollections = try await fetchBookCollectionsUseCase.execute(filter: nil)
        } catch {
            self.errorMessage = "No pudimos cargar tus colecciones."
            print("[BC LIST VM] Error fetching book collections: \(error)")
        }
        
        isLoading = false
    }
}
