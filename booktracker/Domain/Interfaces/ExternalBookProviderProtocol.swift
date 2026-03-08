//
//  ExternalBookProviderProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import Foundation

enum ExternalProviderError: Error {
    case invalidUrl
    case networkError(Error)
    case decodingError
    case noResults
}

protocol ExternalBookProviderProtocol {
    func searchBooks(query: String) async throws -> [Book]
    func getBook(byISBN isbn: String) async throws -> Book?
}
