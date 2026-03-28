//
//  CurrentStreakView.swift
//  booktracker
//
//  Created by Victor rolack on 27-03-26.
//

import SwiftUI

struct CurrentStreakView: View {
    let currentStreak: Int
    var body: some View {
        BTCardView {
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                BTInfoLabelView(value: "\(currentStreak)", label: "Días")
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: 105)
    }
}

#Preview {
    CurrentStreakView(currentStreak: 12)
}
