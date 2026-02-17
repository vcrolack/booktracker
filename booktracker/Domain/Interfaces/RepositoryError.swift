//
//  RepositoryError.swift
//  booktracker
//
//  Created by Victor rolack on 17-02-26.
//

import Foundation

enum RepositoryError: Error, Equatable {
    case notFound
    case saveFailed(reason: String)
    case fetchFailed(reason: String)
    case deleteFailed(reason: String)
}
