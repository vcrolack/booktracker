//
//  BTSessionRowView.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import SwiftUI

struct BTSessionRowView: View {
    let session: ReadingSession
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "book.pages.fill")
                        .foregroundColor(.blue)
                }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(sessionDuration)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if let endPage = session.endPage {
                    let startPage = session.startPage ?? 0
                    let pagesRead = max(0, endPage - startPage)
                    
                    Text("De la página \(startPage) a la \(endPage)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("+\(pagesRead) páginas")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                } else {
                    Text("Sesión en curso o sin finalizar")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var sessionDuration: String {
        guard let endTime = session.endTime else { return "En curso" }
        let duration = endTime.timeIntervalSince(session.startTime)
        let minutes = Int(duration) / 60
        
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMins = minutes % 60
            return "\(hours)h \(remainingMins)m"
        }
    }
}

#Preview {
    let sessionMock = try? ReadingSession(
        bookId: UUID(),
        startTime: Date(),
        endTime: Calendar.current.date(byAdding: .minute, value: 120, to: Date()),
        startPage: 12,
        endPage: 35
    )
    BTSessionRowView(session: sessionMock!)
}
