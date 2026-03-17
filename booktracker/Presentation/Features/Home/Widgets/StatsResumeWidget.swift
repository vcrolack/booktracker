//
//  StatsResumeWidget.swift
//  booktracker
//
//  Created by Victor rolack on 15-03-26.
//

import SwiftUI

struct StatsResumeWidget: View {
    let readingStats: ReadingStats
    let libraryStats: LibraryStats
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            BTCardView {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                    
                    BTInfoLabelView(value: "\(readingStats.currentStreakDays)", label: "Días")
                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: 105)
            
            VStack(spacing: 12) {
                BTInfoLabelView(value: String(format: "%.1f", readingStats.averagePagesPerHour), label: "Pág/h")
                
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 30, height: 4)
                
                BTInfoLabelView(value: "\(readingStats.totalPagesRead)", label: "Páginas")
            }
            .frame(maxWidth: .infinity)
            
            BTCarouselCardView {
                BTInfoLabelView(value: "\(libraryStats.completedBooks)", label: "Leídos", color: .green)
                BTInfoLabelView(value: "\(libraryStats.toReadBooks)", label: "Pendientes", color: .gray)
                BTInfoLabelView(value: "\(libraryStats.startedBooks)", label: "Leyendo", color: .blue)
                BTInfoLabelView(value: "\(libraryStats.abandonedBooks)", label: "Abandonados", color: .red)
            }
            .frame(width: 105)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let readingStatsMock = ReadingStats(totalPagesRead: 10, averagePagesPerHour: 12.0, currentStreakDays: 3)
    let libraryStatsMock = LibraryStats(totalBooks: 27, completedBooks: 3, startedBooks: 1, abandonedBooks: 0, toReadBooks: 23)
    StatsResumeWidget(readingStats: readingStatsMock, libraryStats: libraryStatsMock)
}
