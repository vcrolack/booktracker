//
//  BooksSessionsView.swift
//  booktracker
//
//  Created by Victor rolack on 13-03-26.
//

import SwiftUI

struct BooksSessionsView: View {
    @State var viewModel: BookSessionsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    ProgressView("Cargando historial...")
                        .padding(.top, 50)
                } else if let error = viewModel.errorMessage {
                    
                }
            }
        }
    }
}

#Preview {
    BooksSessionsView(viewModel: DIContainer.shared.makeBookSessionsViewModel(bookId: UUID()))
}
