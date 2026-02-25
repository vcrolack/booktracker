//
//  BookDetailView.swift
//  booktracker
//
//  Created by Victor rolack on 25-02-26.
//

import SwiftUI

struct BookDetailView: View {
    @State var viewModel: BookDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                progressSection
                actionsSection
                metadataSection
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .alert("Abandonar libro", isPresented: $viewModel.showingAbandonAlert) {
            TextField("Razón (Opcional)", text: $viewModel.tempAbandonReason)
            
            Button("Cancelar", role: .cancel) {
                viewModel.tempAbandonReason = ""
            }
            
            Button("Confirmar", role: .destructive) {
                Task {
                    await viewModel.confirmAbandone()
                }
            }
        } message: {
            Text("¿Por qué dejas de leer este libro? Puedes dejar una nota para tu yo del futuro.")
        }
        .sheet(isPresented: $viewModel.showingFinishSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Calificación")) {
                        Picker("Estrellas", selection: $viewModel.tempRating) {
                            ForEach(1...5, id: \.self) { rating in
                                Text(String(repeating: "⭐️", count: rating)).tag(rating)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    
                    Section(
                        header: Text("Reseña"),
                        footer: Text("Opcional: ¿Qué te pareció el libro?")
                    ) {
                        TextEditor(text: $viewModel.tempReview)
                            .frame(minWidth: 100)
                    }
                }
                .navigationTitle("¡Felicidades!")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            viewModel.showingFinishSheet = false
                            viewModel.tempReview = ""
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            Task {
                                await viewModel.confirmFinishReading()
                                viewModel.showingFinishSheet = false
                            }
                        }
                        .bold()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            BTCoverView(urlString: viewModel.book.coverUrl, width: 160, height: 240)
                .frame(width: 160, height: 240)
                .shadow(radius: 10)
        
            VStack(spacing: 8) {
                Text(viewModel.book.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(viewModel.book.author)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                BTBadgeView(
                    text: viewModel.book.status.uiLabel,
                    color: viewModel.book.status.uiColor,
                    iconName: viewModel.book.status.uiIcon
                )
            }
        }
    }
    
    @ViewBuilder
    private var progressSection: some View {
        if viewModel.book.pages > 0 {
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(viewModel.book.currentPage) / \(viewModel.book.pages) páginas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(
                    value: Double(viewModel.book.currentPage),
                    total: Double(viewModel.book.pages)
                )
                .tint(viewModel.book.status.uiColor)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        VStack(spacing: 12) {
            switch viewModel.book.status {
            case .wishlist:
                Button(action: {
                    Task {
                        await viewModel.acquireBookForReading()
                    }
                }) {
                    actionButtonLabel(title: "Para leer", icon: "book.fill", color: .gray)
                }
            case .toRead:
                Button(action: {
                    Task {
                        await viewModel.startReading()
                    }
                }) {
                    actionButtonLabel(title: "Empezar a leer", icon: "book.fill", color: .blue)
                }
            case .reading:
                Button(action: {
                    viewModel.showingFinishSheet = true
                }) {
                    actionButtonLabel(title: "Terminar lectura", icon: "checkmark.circle.fill", color: .green)
                }
                                
                Button(action: {
                    viewModel.showingAbandonAlert = true
                    }) {
                    actionButtonLabel(title: "Abandonar", icon: "xmark.octagon.fill", color: .red, isSecondary: true)
                }
                
            case .finalized, .abandoned:
                EmptyView()
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detalles")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                metadataRow(title: "Propiedad", value: viewModel.book.ownership.rawValue.capitalized)
                Divider().padding(.leading)
                
                if let isbn = viewModel.book.isbn {
                    metadataRow(title: "ISBN", value: isbn)
                }
                
                if let editorial = viewModel.book.editorial {
                    metadataRow(title: "Editorial", value: editorial)
                }
                
                if let genre = viewModel.book.genre {
                    metadataRow(title: "Género", value: genre)
                }
            }
        }
    }
    
    private func actionButtonLabel(title: String, icon: String, color: Color, isSecondary: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title).fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSecondary ? color.opacity(0.1) : color)
        .foregroundColor(isSecondary ? color : .white)
        .cornerRadius(12)
    }
    
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .padding()
    }
}

#Preview {
        let mockBook = try! Book(
            id: UUID(),
            title: "Percy Jackson",
            author: "Rick Riordan",
            pages: 321,
            currentPage: 100,
            ownership: .owner,
            status: .reading,
            coverUrl: "https://images.cdn2.buscalibre.com/fit-in/360x360/89/0d/890d2153424a5a2c45496e4c3de98161.jpg",
            isbn: "123123123123123"
        )

        return NavigationStack {
            BookDetailView(viewModel: DIContainer.shared.makeBookDetailViewModel(book: mockBook))
        }
}
