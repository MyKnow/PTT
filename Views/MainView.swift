//
//  MainView.swift
//  woju
//
//  Created by 정민호 on 1/4/24.
//

import Foundation
import SwiftUI

struct MainView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = false
    @State var selectedTab: Tab = .join

    enum Tab {
        case join, recording, setting
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            JoinView(goIndex:$selectedTab).tabItem {
                Image(systemName: "person.2.wave.2.fill")
                    .modifier(TabItemModifier(selectedTab: .join))
            }
            .tag(Tab.join)
            .onAppear() {
                HapticManager.shared.vibrate()
            }

            RecordingView(goIndex:$selectedTab).tabItem {
                Image(systemName: "mic")
                    .modifier(TabItemModifier(selectedTab: .recording))
            }
            .tag(Tab.recording)
            .onAppear() {
                HapticManager.shared.vibrate()
            }

            SettingView(name: "ERROR", goIndex:$selectedTab).tabItem {
                Image(systemName: "gear")
                    .modifier(TabItemModifier(selectedTab: .setting))
            }
            .tag(Tab.setting)
            .onAppear() {
                HapticManager.shared.vibrate()
            }
        }
        .onAppear() {
            UITabBar.appearance().barTintColor = .black
        }
        .accentColor(.red)
    }
}

struct TabItemModifier: ViewModifier {
    let selectedTab: MainView.Tab

    func body(content: Content) -> some View {
        content
            .imageScale(selectedTab == .join ? .large : .medium)
            .animation(.easeInOut(duration: 0.2))
    }
}

#Preview {
    MainView()
}
