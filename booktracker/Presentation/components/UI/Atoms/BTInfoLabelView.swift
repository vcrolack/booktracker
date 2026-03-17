//
//  BTInfoLabel.swift
//  booktracker
//
//  Created by Victor rolack on 16-03-26.
//

import SwiftUI

struct BTInfoLabelView: View {
    let value: String
    let label: String
    var color: Color = .primary
    var alignment: HorizontalAlignment = .center
    
    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(value)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
    }
}

#Preview {
    BTInfoLabelView(value: "Esto es", label: "UN LABEL")
}
