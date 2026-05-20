//
//  ExternalBookProviderProtocol.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import Foundation

enum ExternalProviderError: Error, LocalizedError {
    case invalidUrl
    case networkError(Error)
    case decodingError
    case noResults
    case noInternetConnection
    case serverError(statusCode: Int)
    case unexpectedError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl: return "La URL no es válida"
        case .networkError(let error): return "Error de conexión: \(error.localizedDescription)"
        case .decodingError: return "Error al decodificar la respuesta"
        case .noResults: return "No se encontraron resultados"
        case .noInternetConnection: return "No hay conexión a internet. Revisa tu red y vuelve a intentarlo"
        case .serverError(let code): return "Ha ocurrido un error en el servidor. (\(code))"
        case .unexpectedError(let message): return "Ha ocurrido un error inesperado: \(message)"
        }
    }
}

protocol ExternalBookProviderProtocol {
    func searchBooks(query: String) async throws -> [Book]
    func getBook(byISBN isbn: String) async throws -> Book?
}
