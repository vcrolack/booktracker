//
//  UpNextBookCell.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

struct UpNextBookCell: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BTCoverView(urlString: book.coverUrl, width: 100, height: 150)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
            
            Text(book.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(width: 100, alignment: .leading)
            
            Text(book.author)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
        }
    }
}

#Preview {
    let mockBook = try! Book(
        id: UUID(),
        title: "Neuromante",
        author: "William Gibson",
        pages: 350,
        currentPage: 120,
        ownership: .owner,
        status: .reading,
        coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg",
        isbn: "9788445074024"
    )
    
    UpNextBookCell(book: mockBook)
}
