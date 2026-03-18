//
//  ApplyZoomTransition.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyZoomTransition(id: UUID, in namespace: Namespace.ID?) -> some View {
        if let namespace = namespace {
            self.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }
}
