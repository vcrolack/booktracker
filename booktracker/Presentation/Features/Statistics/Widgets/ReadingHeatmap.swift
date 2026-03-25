//
//  ReadingHeatmap.swift
//  booktracker
//
//  Created by Victor rolack on 24-03-26.
//

import SwiftUI

struct ReadingHeatmap: View {
    let contributions: [DailyContribution]
    
    let rows = Array(repeating: GridItem(.fixed(12), spacing: 3), count: 7)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 3) {
                ForEach(contributions) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color(for: day.intensity))
                        .frame(width: 12, height: 12)
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func color(for intensity: Int) -> Color {
        switch intensity {
        case 0: return Color.gray.opacity(0.2)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green
        default: return Color.gray.opacity(0.2)
        }
    }
}

#Preview {
    ReadingHeatmap(contributions: (0..<90).map { i in
        DailyContribution(
            date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
            minutes: [0, 10, 25, 45, 80].randomElement()!
        )
    })
}
