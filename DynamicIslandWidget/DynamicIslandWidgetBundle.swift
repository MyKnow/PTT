//
//  DynamicIslandWidgetBundle.swift
//  DynamicIslandWidget
//
//  Created by 정민호 on 1/3/24.
//

import WidgetKit
import SwiftUI

@main
struct DynamicIslandWidgetBundle: WidgetBundle {
    var body: some Widget {
        DynamicIslandWidget()
        DynamicIslandWidgetLiveActivity()
    }
}
