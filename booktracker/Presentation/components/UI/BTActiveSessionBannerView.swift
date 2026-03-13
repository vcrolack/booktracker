//
//  BTActiveSessionBannerView.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import SwiftUI

struct BTActiveSessionBannerView: View {
    let book: Book
    let session: ReadingSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                BTCoverView(urlString: book.coverUrl, width: 40, height: 60)
                    .shadow(radius: 3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lectura en curso")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .textCase(.uppercase)
                    
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "waveform")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .symbolEffect(.variableColor.iterative, options: .repeat(.continuous))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let mockBook = try? Book(
        id: UUID(),
        title: "Neuromante",
        author: "William Gibson",
        pages: 350,
        currentPage: 120,
        ownership: .owner,
        status: .finalized,
        coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg"
    )
    
    let sessionMock = try? ReadingSession(
        bookId: UUID(),
        startTime: Date(),
        endTime: Calendar.current.date(byAdding: .minute, value: 120, to: Date()),
        startPage: 12,
        endPage: 35
    )
    
    BTActiveSessionBannerView(book: mockBook!, session: sessionMock!, onTap: {})
}
