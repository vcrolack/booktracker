//
//  BTHeaderView.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI

struct BTHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .symbolVariant(.fill)
                .imageScale(.medium)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) section")
    }
}

#Preview {
    BTHeaderView(title: "Header vier", icon: "book.fill")
}
