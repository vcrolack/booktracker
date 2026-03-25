//
//  RootView.swift
//  booktracker
//
//  Created by Victor rolack on 25-03-26.
//

import SwiftUI

struct RootView: View {
    @State private var splashIsActive = true
    
    var body: some View {
        ZStack {
            if splashIsActive {
                SplashView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    splashIsActive = false
                }
            }
        }
    }
}

#Preview {
    let mockSessionManager = GlobalSessionManager(getActiveSessionUseCase: DIContainer.shared.makeGetActiveReadingSessionUseCase(), fetchBookUseCase: DIContainer.shared.makeFetchBookUseCase())
    
    RootView()
        .environment(mockSessionManager)
}
