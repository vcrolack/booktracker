//
//  SplashView.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI
import Lottie

struct SplashView: View {
    private let animationName = "splash_screen_booktracker"
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                LottieView {
                    try await DotLottieFile.named(animationName)
                }
                .configuration(LottieConfiguration(renderingEngine: .mainThread))
                .playing(loopMode: .playOnce)
                .animationSpeed(1.2)
                .frame(width: 280, height: 280)
                
                Text("BookTracker")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .opacity(0.8)
                
                Spacer()
                
                Text("Cultivando el hábito")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    SplashView()
}
