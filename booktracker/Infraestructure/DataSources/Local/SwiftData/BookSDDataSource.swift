//
//  SwiftDataLocalDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import SwiftData

protocol BookLocalDataSourceProtocol {
    func save(book: Book) throws
    func fetchBook(by id: UUID) throws -> Book?
    func fetchBooks(matching filter: BookFilter?) throws -> [Book]
    func deleteBook(by id: UUID) throws
}

final class BookSDDataSource: BookLocalDataSourceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save (book: Book) throws {
        do {
            let bookSD = BookMapper.toDataModel(from: book)
            context.insert(bookSD)
            try context.save()
        } catch {
            throw DataSourceError.saveFailed(error.localizedDescription)
        }
    }
    
    func fetchBook(by id: UUID) throws -> Book? {
        do {
            var descriptor = FetchDescriptor<BookSD>(
                predicate: #Predicate { $0.id == id }
            )
            
            descriptor.fetchLimit = 1
            
            guard let bookSD = try context.fetch(descriptor).first else {
                return nil
            }
            
            return BookMapper.toDomain(from: bookSD)
        } catch {
            throw DataSourceError.fetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Fetch All (Con Filtro y Ordenamiento Híbrido)
        func fetchBooks(matching filter: BookFilter? = nil) throws -> [Book] {
            do {
                // 1. 🚦 RESOLVER EL ORDENAMIENTO (Igual que antes)
                var sortDescriptors: [SortDescriptor<BookSD>] = []
                let activeSort = filter?.sortBy ?? .createdAtAscending
                
                switch activeSort {
                case .titleAscending:
                    sortDescriptors.append(SortDescriptor(\.title, order: .forward))
                case .createdAtAscending:
                    sortDescriptors.append(SortDescriptor(\.createdAt, order: .forward))
                case .createdAtDescending:
                    sortDescriptors.append(SortDescriptor(\.createdAt, order: .reverse))
                case .ratingDescending:
                    sortDescriptors.append(SortDescriptor(\.userRating, order: .reverse))
                }
                
                var descriptor = FetchDescriptor<BookSD>(sortBy: sortDescriptors)
                
                // 2. 🔍 FILTRO PESADO EN SQLITE (#Predicate simple para que el compilador no sufra)
                if let searchItem = filter?.searchItem, !searchItem.isEmpty {
                    descriptor.predicate = #Predicate<BookSD> { book in
                        // Solo le dejamos a SQLite la búsqueda de texto, que es lo más costoso
                        book.title.contains(searchItem) || book.author.contains(searchItem)
                    }
                }
                
                // 3. 🚀 Ejecutar la consulta base en la Base de Datos
                // Lo hacemos 'var' para poder aplicar los filtros restantes en memoria
                var booksSD = try context.fetch(descriptor)
                
                // 4. ⚡️ FILTROS RÁPIDOS EN MEMORIA
                // Una vez que tenemos los datos, aplicamos los filtros exactos usando Swift puro.
                if let activeFilter = filter {
                    
                    if let status = activeFilter.status {
                        booksSD = booksSD.filter { $0.statusRawValue == status.rawValue }
                    }
                    
                    if let ownership = activeFilter.ownership {
                        booksSD = booksSD.filter { $0.ownershipRawValue == ownership.rawValue }
                    }
                    
                    if let genre = activeFilter.genre, !genre.isEmpty {
                        booksSD = booksSD.filter { $0.genre == genre }
                    }
                }
                
                // 5. 📦 Traducir a Entidades de Dominio
                return booksSD.map { BookMapper.toDomain(from: $0) }
                
            } catch {
                throw DataSourceError.fetchFailed(error.localizedDescription)
            }
        }
    
    func deleteBook(by id: UUID) throws {
        do {
            let descriptor = FetchDescriptor<BookSD>(predicate: #Predicate { $0.id == id })
            
            if let bookSD = try context.fetch(descriptor).first {
                context.delete(bookSD)
                try context.save()
            }
        } catch {
            throw DataSourceError.deleteFailed(error.localizedDescription)
        }
    }
}
