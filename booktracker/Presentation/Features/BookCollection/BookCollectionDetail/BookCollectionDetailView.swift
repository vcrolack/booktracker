//
//  BookCollectionDetailView.swift
//  booktracker
//
//  Created by Victor rolack on 19-03-26.
//

import SwiftUI

struct BookCollectionDetailView: View {
    @State var viewModel: BookCollectionDetailViewModel
    @State var showingBookSelector: Bool = false
    @State var showingEditorForm: Bool = false
    
    private let imageProcessor: ImageProcessorService = DIContainer.shared.makeImageProcessor()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                if !viewModel.books.isEmpty {
                    statusSummaryRow
                }
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if viewModel.books.isEmpty {
                    emptyState
                } else {
                    Button{
                        showingBookSelector = true
                    } label: {
                        Image(systemName: "plus")
                        Text("Agregar libros")
                    }
                    bookList
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
        }
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") {
                    showingEditorForm = true
                }.foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingBookSelector) {
            BookSelectionView(viewModel: DIContainer.shared.makeBookSelectionViewModel(initialSelectedIds: viewModel.bookCollection.bookIds)) { updatedIds in
                Task { await viewModel.updateBooks(newIds: updatedIds) }
            }
        }
        .sheet(isPresented: $showingEditorForm, onDismiss: {
            Task { await viewModel.refreshData() }
        }) {
            BookCollectionFormView(viewModel: DIContainer.shared.makeBookCollectionFormViewModel(collectionToEdit: viewModel.bookCollection))
        }
        .task { await viewModel.loadBooks() }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let fileName = viewModel.bookCollection.cover,
               let uiImage = imageProcessor.loadImage(fileName: fileName, folderName: "CollectionCovers") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                    .overlay(.ultraThinMaterial)
                
                HStack(alignment: .bottom, spacing: 15) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 140)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.bookCollection.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                            
                        if let desc = viewModel.bookCollection.description {
                            Text(desc)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Text("\(viewModel.books.count) libros")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                        
                    }
                    .padding(10)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var bookList: some View {
        LazyVStack(spacing: 20) {
            ForEach(viewModel.books) { book in
                NavigationLink(destination: BookDetailView(viewModel: DIContainer.shared.makeBookDetailViewModel(book: book))) {
                    bookCell(book: book)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func bookCell(book: Book) -> some View {
        BTCardView {
            HStack(alignment: .center, spacing: 12) {
                // 1. 🖼️ Cover (Leading)
                BTCoverView(urlString: book.coverUrl)
                    .frame(width: 50, height: 75) // Tamaño consistente para listas
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)

                // 2. 📝 Información (Center)
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer() // Empuja el badge al extremo derecho

                // 3. 🏷️ Estado (Trailing)
                BTBadgeView(
                    text: book.status.uiLabel,
                    color: book.status.uiColor,
                    iconName: book.status.uiIcon
                )
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 15) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("Esta colección está vacía")
                .font(.headline)
            Button("Añadir libros") {
                showingBookSelector = true
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 50)
    }
    
    @ViewBuilder
    private var statusSummaryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Recorremos todos los posibles estados del Enum
                ForEach(BookStatus.allCases, id: \.self) { status in
                    let count = viewModel.bookCountsByStatus[status, default: 0]
                    
                    // Solo mostramos el badge si hay al menos 1 libro en ese estado
                    if count > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: status.uiIcon)
                                .font(.system(size: 10, weight: .bold))
                            
                            Text("\(count)")
                                .font(.caption.bold())
                            
                            Text(status.uiLabel)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(status.uiColor.opacity(0.15))
                        .foregroundColor(status.uiColor)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    let mockBookCollection = try? BookCollection(name: "Test Collection", description: "A test collection")
    BookCollectionDetailView(
        viewModel: DIContainer.shared.makeBookCollectionDetailViewModel(bookCollection: mockBookCollection!)
    )
}
