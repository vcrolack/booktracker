//
//  UpdateBookCollectionCommand.swift
//  booktracker
//
//  Created by Victor rolack on 20-02-26.
//

import Foundation

struct UpdateBookCollectionCommand {
    let bookCollectionId: UUID
    var name: String?
    var description: String?
    var cover: String?
}
