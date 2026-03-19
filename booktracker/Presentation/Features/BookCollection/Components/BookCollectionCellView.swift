//
//  BookCollectionCellView.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import SwiftUI

struct BookCollectionCellView: View {
    @State private var uiImage: UIImage? = nil
    let bookCollection: BookCollection

    private let imageProcessor = DIContainer.shared.makeImageProcessor()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 230)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    placeholderView
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "folder.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
            }
            .frame(width: 160, height: 230)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)
            
            Text(bookCollection.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text("\(bookCollection.bookIds.count) libros")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 160)
        .task { await loadImage() }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.secondarySystemBackground))
            .frame(width: 160, height: 230)
            .overlay(
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.largeTitle)
                    .foregroundStyle(.gray.opacity(0.5))
            )
    }
    
    private func loadImage() async {
        guard let fileName = bookCollection.cover else { return }
        
        let loadedImage = imageProcessor.loadImage(fileName: fileName, folderName: "CollectionCovers")
        
        await MainActor.run {
            self.uiImage = loadedImage
        }
    }
}

#Preview {
    let bookCollectionMock = try? BookCollection(name: "Favoritos 2025", description: "Estos son mis favoritos del 2025")
    BookCollectionCellView(
        bookCollection: bookCollectionMock!
    )
}
