//
//  BTSectionHeaderView.swift
//  booktracker
//
//  Created by Victor rolack on 14-03-26.
//

import SwiftUI

struct BTSectionHeaderView<Destination: View>: View {
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        BTSectionHeaderView(title: "Hello", destination: Text("Hello"))
    }
}
