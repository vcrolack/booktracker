//
//  GoogleBooksProvider.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import Foundation

class GoogleBooksProvider: ExternalBookProviderProtocol {
    private let session: URLSession
    private let baseUrl = "https://www.googleapis.com/books/v1/volumes"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchBooks(query: String) async throws -> [Book] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseUrl)?q=\(encodedQuery)&maxResults=40") else{
            throw ExternalProviderError.invalidUrl
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw ExternalProviderError.networkError(NSError(domain: "Invalid HTTP response", code: 0))
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(GoogleBooksSearchResponseDTO.self, from: data)
            
            guard let items = searchResponse.items else {
                return []
            }
            
            let books = items.compactMap { GoogleBookMapper.toDomain(dto: $0) }
            
            return books
        } catch let error as DecodingError {
            print("[Google Books] Error decoding google books: \(error)")
            throw ExternalProviderError.decodingError
        } catch {
            throw ExternalProviderError.networkError(error)
        }
    }
    
    func getBook(byISBN isbn: String) async throws -> Book? {
        let books = try await searchBooks(query: "isbn:\(isbn)")
        return books.first
    }
}
