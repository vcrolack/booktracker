//
//  GoogleBooksMapper.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import Foundation

struct GoogleBookMapper {
    static func toDomain(dto: GoogleBookItemDTO) -> Book? {
        let info = dto.volumeInfo
        
        let author = info.authors?.first ?? "Autor desconocido"
        
        let pages = info.pageCount ?? 0
        
        var secureCoverUrl: String? = nil
        if let rawUrl = info.imageLinks?.thumbnail ?? info.imageLinks?.smallThumbnail {
            secureCoverUrl = rawUrl.replacingOccurrences(of: "http://", with: "https://")
        }
        
        let isbn13 = info.industryIdentifiers?.first(where: { $0.type == "ISBN_13"})?.identifier
        
        do {
            let book = try Book(
                title: info.title,
                author: author,
                pages: pages,
                currentPage: 0,
                ownership: .notOwner,
                status: .wishlist,
                coverUrl: secureCoverUrl,
                isbn: isbn13,
                editorial: info.publisher,
                genre: info.categories?.first,
                overview: info.description,
            )
            return book
        } catch {
            print("[GOOGLE BOOKS] Error mapping book: \(error)")
            return nil
        }
    }
}
