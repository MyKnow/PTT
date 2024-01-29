//
//  DynamicIslandWidgetLiveActivity.swift
//  DynamicIslandWidget
//
//  Created by 정민호 on 1/3/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DynamicIslandWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var value: Int
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
    var totalNum = 100.0
}

struct DynamicIslandWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DynamicIslandWidgetAttributes.self) { context in
            
            // 잠금 화면에 뜨는 알림창
            VStack(alignment: .leading) {
                Text("잠금화면에 뜨는 Live Activity")
                Text("세션 이름: \(context.attributes.name)")
                Text(" \(context.state.value)")
            }
            .padding(.leading)
            .activityBackgroundTint(Color.black)
            .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            // DynamicIsland
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("시작")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("끝")
                }
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Image(systemName: "heart.fill").tint(.red)
                        Text("진행률")
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView("", value: Double(context.state.value) / context.attributes.totalNum)
                }
            } compactLeading: {
                Text("0")
            } compactTrailing: {
                Text("100")
            } minimal: {
                // 다른앱에서도 live activiy가 있어서 떠있을때 작은 원모양으로 보여짐
                Text("A앱")
            }
        }
    }
}
