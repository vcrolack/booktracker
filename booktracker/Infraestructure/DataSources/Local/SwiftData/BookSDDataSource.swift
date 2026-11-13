//
//  SwiftDataLocalDataSource.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import SwiftData

protocol BookLocalDataSourceProtocol: Sendable {
    func save(book: Book) async throws
    func fetchBook(by id: UUID) async throws -> Book?
    func fetchBooks(matching filter: BookFilter?) async throws -> [Book]
    func deleteBook(by id: UUID) async throws
}

@ModelActor
actor BookSDDataSource: BookLocalDataSourceProtocol {
    func save(book: Book) throws {
        do {
            let bookId = book.id
            
            // 1. 🔍 Buscamos si el libro ya existe en la base de datos
            var descriptor = FetchDescriptor<BookSD>(predicate: #Predicate { $0.id == bookId })
            descriptor.fetchLimit = 1
            
            if let existingBookSD = try modelContext.fetch(descriptor).first {
                // 🔄 2A. MODO EDICIÓN: Mutamos el objeto que SwiftData ya está rastreando
                existingBookSD.title = book.title
                existingBookSD.author = book.author
                existingBookSD.overview = book.overview
                existingBookSD.pages = book.pages
                existingBookSD.currentPage = book.currentPage
                existingBookSD.editorial = book.editorial
                existingBookSD.isbn = book.isbn
                existingBookSD.statusRawValue = book.status.rawValue
                existingBookSD.ownershipRawValue = book.ownership.rawValue
                existingBookSD.coverUrl = book.coverUrl
                existingBookSD.genre = book.genre
                existingBookSD.globalRating = book.globalRating
                existingBookSD.userRating = book.userRating
                existingBookSD.userReview = book.userReview
                existingBookSD.startDate = book.startDate
                existingBookSD.endDate = book.endDate
                existingBookSD.abandonReason = book.abandonReason
                existingBookSD.updatedAt = book.updatedAt
                // 💡 Nota: No actualizamos 'createdAt' para no perder la fecha original
                
            } else {
                // ✨ 2B. MODO CREACIÓN: Es un libro totalmente nuevo, lo insertamos
                let newBookSD = BookMapper.toDataModel(from: book)
                modelContext.insert(newBookSD)
            }
            
            // 3. 💾 Guardamos los cambios de contexto (SwiftData sabrá si hacer INSERT o UPDATE)
            try modelContext.save()
            
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
            
            guard let bookSD = try modelContext.fetch(descriptor).first else {
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
                
                if let searchItem = filter?.searchItem, !searchItem.isEmpty {
                    descriptor.predicate = #Predicate<BookSD> { book in
                        book.title.contains(searchItem) || book.author.contains(searchItem)
                    }
                }
                
                // 3. 🚀 Ejecutar la consulta base en la Base de Datos
                // Lo hacemos 'var' para poder aplicar los filtros restantes en memoria
                var booksSD = try modelContext.fetch(descriptor)
                
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
                    
                    if let ids = activeFilter.ids {
                        print("🔍 Buscando libros con IDs: \(ids)")
                        print("📚 Libros disponibles en DB: \(booksSD.map { $0.id })")
                        booksSD = booksSD.filter { ids.contains($0.id) }
                        print("✅ Encontrados: \(booksSD.count)")
                    }
                    
                    if let finishYear = activeFilter.finishYear {
                        booksSD = booksSD.filter { book in
                            guard let endDate = book.endDate else { return false}
                            let yearOfCompletion = Calendar.current.component(.year, from: endDate)
                            return yearOfCompletion == finishYear
                        }
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
            
            if let bookSD = try modelContext.fetch(descriptor).first {
                modelContext.delete(bookSD)
                try modelContext.save()
            }
        } catch {
            throw DataSourceError.deleteFailed(error.localizedDescription)
        }
    }
}
