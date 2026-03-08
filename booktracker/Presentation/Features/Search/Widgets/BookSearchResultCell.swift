//
//  BookSearchResultCell.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

struct BookSearchResultCell: View {
    let book: Book
    let isSaved: Bool
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            BTCoverView(urlString: book.coverUrl, width: 60, height: 90)
                .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if let genre = book.genre {
                        Text(genre)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                    
                    Text("\(book.pages) pág.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                guard !isSaved else { return }
                onSave()
                // TODO: execute create book use case
            }) {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(isSaved ? .green : .blue)
                    .contentTransition(.symbolEffect(.replace))
            }
            .disabled(isSaved)
        }
        .padding(.vertical, 8)
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
    BookSearchResultCell(book: mockBook, isSaved: false, onSave: {})
}
