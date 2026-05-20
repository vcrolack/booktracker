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
                BTCoverView(urlString: book.coverUrl, width: 20, height: 30)
                    .shadow(radius: 2, y: 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lectura en curso")
                        .font(.caption2)
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
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 50)
            .contentShape(Rectangle())
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
