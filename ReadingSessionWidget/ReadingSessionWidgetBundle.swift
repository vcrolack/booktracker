//
//  ReadingSessionWidgetBundle.swift
//  ReadingSessionWidget
//
//  Created by Victor rolack on 14-03-26.
//

import WidgetKit
import SwiftUI

@main
struct ReadingSessionWidgetBundle: WidgetBundle {
    var body: some Widget {
        ReadingSessionWidget()
        ReadingSessionWidgetControl()
        ReadingSessionWidgetLiveActivity()
    }
}
