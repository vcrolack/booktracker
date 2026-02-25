//
//  BookListView.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import SwiftUI

struct BookListView: View {
    @State var viewModel: BookListViewModel
    @State private var searchText: String = ""
    @State private var selectedFilter: BookStatus? = nil
    @State private var showingAddBook: Bool = false
    
    private var filteredBooks: [Book] {
        if let filter = selectedFilter {
            return viewModel.books.filter { $0.status == filter }
        }
        return viewModel.books
    }
    
    // MARK: - 📱 Body Principal (Índice visual)
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
                mainContent
            }
            .navigationTitle("Mi Biblioteca")
            .searchable(text: $searchText, prompt: "Buscar por título o autor...")
            .onChange(of: searchText) { oldValue, newValue in
                Task { await viewModel.updateSearchTerm(newValue) }
            }
            .task {
                await viewModel.fetchBooks()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                Task {
                    await viewModel.fetchBooks()
                }
            } content: {
                AddBookView(viewModel: DIContainer.shared.makeAddBookViewModel())
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - 🧩 Fragmentos de la Vista
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                BTFilterChipView(
                    title: "Todos",
                    isSelected: selectedFilter == nil,
                    iconName: "square.grid.2x2.fill",
                    color: .primary,
                   
                ) {
                    selectedFilter = nil
                }
                
                ForEach(BookStatus.allCases, id: \.self) { status in
                    BTFilterChipView(
                        title: status.uiLabel,
                        isSelected: selectedFilter == status,
                        iconName: status.uiIcon,
                        color: status.uiColor,
                        
                    ) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    @ViewBuilder
    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando tu biblioteca...")
            } else if let errorMessage = viewModel.errorMessage {
                BTErrorState(errorMessage: errorMessage) {
                    Task { await viewModel.fetchBooks() }
                }
            } else if filteredBooks.isEmpty {
                BTEmptyStateView(
                    title: "No hay libros",
                    iconName: "book.fill",
                    description: "¡Prueba agregando libros!"
                )
            } else {
                bookList
            }
        }
    }
    
    private var bookList: some View {
        List {
            ForEach(filteredBooks) { book in
                BTCardView {
                    HStack(alignment: .top, spacing: 12) {
                        BTCoverView(urlString: book.coverUrl)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title).font(.headline)
                            Text(book.author).font(.subheadline).foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        BTBadgeView(
                            text: book.status.uiLabel,
                            color: book.status.uiColor,
                            iconName: book.status.uiIcon
                        )
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    BookListView(viewModel: DIContainer.shared.makeBookListViewModel())
}
