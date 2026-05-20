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
    var compactNumberformat: Bool = false
    
    private var displayValue: String {
        if compactNumberformat, let intValue = Int(value) {
            return intValue.formatted(.number.notation(.compactName))
        }
        
        return value
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(displayValue)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
    }
}

#Preview {
    BTInfoLabelView(value: "18000", label: "UN LABEL", compactNumberformat: true)
}
