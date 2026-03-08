//
//  ExpandableSynopsisWidget.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

struct ExpandableSynopsisWidget: View {
    let text: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sinopsis")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .lineLimit(isExpanded ? nil : 4)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Text(isExpanded ? "Ocultar" : "Leer más")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

#Preview {
    ExpandableSynopsisWidget(text: "Lorem ipsun bla bla bla")
}
