//
//  BookSelectionViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 20-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class BookSelectionViewModel {
    var allBooks: [Book] = []
    var selectedIds: Set<UUID> = []
    var searchText: String = ""
    var isLoading: Bool = false
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return allBooks
        } else {
            return allBooks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(initialSelectedIds: Set<UUID>, fetchBooksUseCase: FetchBooksUseCaseProtocol) {
        self.selectedIds = initialSelectedIds
        self.fetchBooksUseCase = fetchBooksUseCase
    }
    
    func loadBooks() async {
        isLoading = true
        
        do {
            self.allBooks = try await fetchBooksUseCase.execute(filter: nil)
        } catch {
            print("[BOOK SELECTION VIEW MODEL] Failed to load books: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func toggleSelection(for id: UUID) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}
