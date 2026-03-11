//
//  BTAmbientBackgroundView.swift
//  booktracker
//
//  Created by Victor rolack on 11-03-26.
//

import SwiftUI

struct BTAmbientBackgroundView: View {
    let urlString: String?
    var animationDuration: TimeInterval = 1.0
    var baseOpacity: Double = 0.6
    var overlayOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
//                .ignoresSafeArea(edges: ignoredEdges)
            
            AsyncImage(
                url: URL(string: urlString ?? ""),
                transaction: Transaction(animation: .easeInOut(duration: animationDuration))
            ) { phase in
                if let image = phase.image {
                    ZStack {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
//                            .ignoresSafeArea()
                            .blur(radius: 80, opaque: true)
                            .opacity(baseOpacity)
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
//                            .ignoresSafeArea(edges: ignoredEdges)
                            .blur(radius: 80, opaque: true)
                            .opacity(baseOpacity)
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
