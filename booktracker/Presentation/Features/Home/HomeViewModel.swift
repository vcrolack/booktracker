//
//  HomeViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 06-03-26.
//

import Foundation
import Observation

@MainActor
@Observable
class HomeViewModel {
    private var allBooks: [Book] = []

    var showingActiveSessionSheet: Bool = false

    var currentReadingBooks: [Book] {
        allBooks
            .filter { $0.status == .reading }
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(3)
            .map { $0 }
    }
    
    var upNextBooks: [Book] {
        allBooks
            .filter { $0.status == .toRead }
            .prefix(3)
            .map { $0 }
    }
    
    var recentlyFinishedBooks: [Book] {
        allBooks
            .filter { $0.status == .finalized }
            .sorted { ($0.endDate ?? Date.distantPast) > ($1.endDate ?? Date.distantPast) }
            .prefix(3)
            .map { $0 }
    }
    
    private var showingAddBookForm: Bool = false
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    private let getActiveSessionUseCase: GetActiveReadingSessionUseCaseProtocol
    
    init(fetchBooksUseCase: FetchBooksUseCaseProtocol, getActiveSessionUseCase: GetActiveReadingSessionUseCaseProtocol) {
        self.fetchBooksUseCase = fetchBooksUseCase
        self.getActiveSessionUseCase = getActiveSessionUseCase
    }
    
    func loadDashboard() async {
        do {
            self.allBooks = try await fetchBooksUseCase.execute(filter: nil)
        } catch {
            print("Error cargando dashboard: \(error.localizedDescription)")
        }
    }
}
