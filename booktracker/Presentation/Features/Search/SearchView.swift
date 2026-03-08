//
//  SearchView.swift
//  booktracker
//
//  Created by Victor rolack on 08-03-26.
//

import SwiftUI

struct SearchView: View {
    @State var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "Buscar libros",
                        systemImage: "magnifyingglass",
                        description: Text("Busca por título, autor o ISBN.")
                    )
                } else if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Buscando libros...")
                            .foregroundColor(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Ups, algo falló",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.books.isEmpty {
                    ContentUnavailableView(
                        "Sin resultados",
                        systemImage: "book.closed",
                        description: Text("No encontramos nada que coincida con \(viewModel.searchText).")
                    )
                } else {
                    List(viewModel.books) { book in
                        BookSearchResultCell(
                            book: book,
                            isSaved: book.isbn != nil ? viewModel.savedBookISBNs.contains(book.isbn!) : false,
                            onSave: {
                                viewModel.saveBook(book)
                            }
                        )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Buscar libros")
            .navigationTitle("Explorar")
            .task {
                await viewModel.loadSavedBooks()
            }
        }
    }
}

#Preview {
    SearchView(viewModel: DIContainer.shared.makeSearchViewModel())
}
