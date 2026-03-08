//
//  SearchViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import Foundation
import Observation

@MainActor
@Observable
class SearchViewModel {
    var savedBookISBNs: Set<String> = []
    var searchText: String = "" {
        didSet {
            performSearchWithDebounce()
        }
    }
    
    var books: [Book] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let searchUseCase: SearchExternalBooksUseCaseProtocol
    private let createBookUseCase: CreateBookUseCaseProtocol
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    
    private var searchTask: Task<Void, Never>?
    
    init(
        searchUseCase: SearchExternalBooksUseCaseProtocol,
        createBookUseCase: CreateBookUseCaseProtocol,
        fetchBooksUseCase: FetchBooksUseCaseProtocol
    ) {
        self.searchUseCase = searchUseCase
        self.createBookUseCase = createBookUseCase
        self.fetchBooksUseCase = fetchBooksUseCase
    }
    
    private func performSearchWithDebounce() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            searchTask?.cancel()
            books = []
            isLoading = false
            errorMessage = nil
            return
        }
        
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                
                if Task.isCancelled { return }
                
                self.isLoading = true
                self.errorMessage = nil
                
                let results = try await searchUseCase.execute(query: query)
                
                if Task.isCancelled { return }
                
                self.books = results
                self.isLoading = false
            } catch is CancellationError {
                print("Search cancelled by user (typing too fast")
            } catch {
                if Task.isCancelled { return }
                
                self.isLoading = false
                self.errorMessage = "No pudimos encontrar libros. Intenta otra vez."
                self.books = []
                print("[SEARCH VIEW MODEL] Error in search: \(error.localizedDescription)")
            }
        }
    }
    
    func saveBook(_ book: Book) {
        Task {
            do {
                let command = CreateBookCommand(
                    title: book.title,
                    author: book.author,
                    pages: book.pages,
                    ownership: book.ownership,
                    status: book.status,
                    isbn: book.isbn,
                    coverUrl: book.coverUrl,
                    editorial: book.editorial,
                    genre: book.genre,
                    overview: book.overview,
                    currentPage: book.currentPage
                )
                let _ = try await createBookUseCase.execute(command: command)
                
                if let isbn = book.isbn {
                    self.savedBookISBNs.insert(isbn)
                }
                
                print("[SEARCH VIEW MODEL] book saved successfuly: \(book.title)")
            } catch {
                self.errorMessage = "No pudimos guardar el libro en tu biblioteca."
                print("[SEARCH VIEW MODEL] error saving book: \(error.localizedDescription)")
            }
        }
    }
    
    func loadSavedBooks() async {
        do {
            let localBooks = try await fetchBooksUseCase.execute(filter: nil)
            let isbns = localBooks.compactMap { $0.isbn }
            self.savedBookISBNs = Set(isbns)
            
            print("[SEARCH VIEW MODEL] Sync local books completed: \(savedBookISBNs.count) books knew")
        } catch {
            print("[SEARCH VIEW MODEL] Sync local books failed: \(error.localizedDescription)")
        }
    }
}
