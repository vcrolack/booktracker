//
//  BTBadgeView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BTBadgeView: View {
    let text: String
    let color: Color
    var iconName: String? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.system(size: 10, weight: .bold))
            }
            
            Text(text.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Puede usarse para un libro...
        BTBadgeView(text: "Finalizado", color: .green, iconName: "checkmark.seal.fill")
        // ...o para una meta...
        BTBadgeView(text: "Meta Lograda", color: .purple, iconName: "trophy.fill")
        // ...o sin ícono!
        BTBadgeView(text: "Nuevo", color: .blue)
    }
    .padding()
}
