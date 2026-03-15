//
//  CurrentReadingWidget.swift
//  booktracker
//
//  Created by Victor rolack on 06-03-26.
//

import SwiftUI

struct CurrentReadingWidget: View {
    @Environment(GlobalSessionManager.self) private var sessionManager
    let book: Book
    let onStartReading: () -> Void
    
    private var progressPercentage: Double {
        guard book.pages > 0 else { return 0 }
        return Double(book.currentPage) / Double(book.pages)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                BTCoverView(urlString: book.coverUrl, width: 80, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Spacer(minLength: 0)
                    
                    VStack(spacing: 6) {
                        HStack {
                            Text("\(book.currentPage) / \(book.pages) pág.")
                                .font(.caption2)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: progressPercentage)
                            .tint(.blue)
                    }
                }
            }.frame(height: 120)
            
            Button(action: {
                onStartReading()
            }) {
                HStack {
                    Image(systemName: isThisBookActive ? "bookmark.fill" : "play.fill")
                    Text(isThisBookActive ? "Lectura en curso" : "Registrar lectura")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isThisBookActive ? Color.green.opacity(0.2) :  Color.blue.opacity(0.1))
                .foregroundColor(isThisBookActive ? .green : .blue)
                .cornerRadius(10)
            }
            .disabled(isAnySessionActive)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .opacity(isAnySessionActive && !isThisBookActive ? 0.6 : 1.0)
    }
    
    private var isThisBookActive: Bool {
        sessionManager.activeBook?.id == book.id
    }
    
    private var isAnySessionActive: Bool {
        sessionManager.activeSession != nil
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
    
    ZStack {
        Color(UIColor.systemGroupedBackground).ignoresSafeArea()
        
        CurrentReadingWidget(book: mockBook, onStartReading: {})
            .padding()
    }
}
