//
//  FinishedBookCell.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

struct FinishedBookCell: View {
    let book: Book
    var body: some View {
        HStack(spacing: 16) {
            BTCoverView(urlString: book.coverUrl, width: 50, height: 75)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("Completado")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                    
                    if let rating = book.userRating, rating > 0 {
                        HStack(spacing: 2) {
                            let ratingInt = Int(rating)
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= ratingInt ? "star.fill" : "star")
                                    .foregroundColor(index <= ratingInt ? .yellow : .gray.opacity(0.3))
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

#Preview {
    let mockBook: Book = {
        var book = try! Book(
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
        try! book.finishReading(rating: 4.0)
        return book
    }()
    
    FinishedBookCell(book: mockBook)
}
