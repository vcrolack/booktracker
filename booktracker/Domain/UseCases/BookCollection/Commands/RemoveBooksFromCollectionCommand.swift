//
//  RemoveBooksFromCollectionCommand.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

struct RemoveBooksFromCollectionCommand {
    let collectionId: UUID
    let bookIds: Set<UUID>
}
