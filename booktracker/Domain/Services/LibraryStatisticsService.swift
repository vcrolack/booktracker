//
//  LibraryStatisticsService.swift
//  booktracker
//
//  Created by Victor rolack on 15-03-26.
//

struct  LibraryStats {
    let totalBooks: Int
    let completedBooks: Int
    let startedBooks: Int
    let abandonedBooks: Int
    let toReadBooks: Int
}

protocol LibraryStatisticsServiceProtocol {
    func calculateStats(from books: [Book]) -> LibraryStats
}

struct LibraryStatisticsService: LibraryStatisticsServiceProtocol {
    
    func calculateStats(from books: [Book]) -> LibraryStats {
        guard !books.isEmpty else {
            return LibraryStats(totalBooks: 0, completedBooks: 0, startedBooks: 0, abandonedBooks: 0, toReadBooks: 0)
        }
        
        let counts = books.reduce(into: [BookStatus: Int]()) { dict, book in
            dict[book.status, default: 0] += 1
        }
        
        return LibraryStats(
            totalBooks: books.count,
            completedBooks: counts[.finalized] ?? 0,
            startedBooks: counts[.reading] ?? 0,
            abandonedBooks: counts[.abandoned] ?? 0,
            toReadBooks: counts[.toRead] ?? 0
        )
    }
    
    private func calculate(books: [Book], withStatus status: BookStatus) -> Int {
        books.filter { $0.status == status }.count
    }
}
