//
//  SwiftDataSourceInterface.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation

enum DataSourceError: Error, Equatable {
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
}
