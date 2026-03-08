//
//  GoogleBooksDTO.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

//
//  GoogleBooksDTO.swift
//  booktracker
//

import Foundation

// MARK: - 📦 Respuesta de Búsqueda (/volumes?q=...)
struct GoogleBooksSearchResponseDTO: Codable {
    let items: [GoogleBookItemDTO]?
}

// MARK: - 📘 El Libro Individual (Equivalente a tu "Welcome")
struct GoogleBookItemDTO: Codable {
    let id: String
    let volumeInfo: GoogleVolumeInfoDTO
}

// MARK: - 📄 Metadata (Todo opcional excepto el título)
struct GoogleVolumeInfoDTO: Codable {
    let title: String
    let authors: [String]?
    let publisher: String?
    let description: String?
    let pageCount: Int?
    let categories: [String]?
    let imageLinks: GoogleImageLinksDTO?
    let industryIdentifiers: [GoogleIndustryIdentifierDTO]? // Para sacar el ISBN
}

// MARK: - 🖼️ Portadas
struct GoogleImageLinksDTO: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
}

// MARK: - 🏷️ Identificadores (ISBN)
struct GoogleIndustryIdentifierDTO: Codable {
    let type: String
    let identifier: String
}

// MARK: - SaleInfo
struct SaleInfo: Codable {
    let country, saleability: String
    let isEbook: Bool
}

// MARK: - VolumeInfo
struct VolumeInfo: Codable {
    let title: String
    let authors: [String]
    let publisher, publishedDate, description: String
    let readingModes: ReadingModes
    let pageCount, printedPageCount: Int
    let dimensions: Dimensions
    let printType: String
    let averageRating, ratingsCount: Int
    let maturityRating: String
    let allowAnonLogging: Bool
    let contentVersion: String
    let panelizationSummary: PanelizationSummary
    let imageLinks: ImageLinks
    let language: String
    let previewLink: String
    let infoLink, canonicalVolumeLink: String
}

// MARK: - Dimensions
struct Dimensions: Codable {
    let height: String
}

// MARK: - ImageLinks
struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String
}

// MARK: - PanelizationSummary
struct PanelizationSummary: Codable {
    let containsEpubBubbles, containsImageBubbles: Bool
}

// MARK: - ReadingModes
struct ReadingModes: Codable {
    let text, image: Bool
}
