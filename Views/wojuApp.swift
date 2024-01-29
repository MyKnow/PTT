//
//  wojuApp.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import SwiftUI

@main
@available(iOS 16.1, *)
struct wojuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true

    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                OnboardingView()
            } else {
                MainView()
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        print("앱 델리게이트 초기화")
        AudioManager.shared.setMaxVolume()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 단축어 설정
        ShortcutsManager.shared.setup()
        print("단축어 설정 완료")
        return true
    }

    // continue 메서드의 공개(public) 시그니처 사용
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // 단축어의 활동 유형 확인
        let activityType = userActivity.activityType
        if activityType == ShortcutsManager.Suggestion.bookmark.type {
            // AudioManager의 녹음 시작 함수 호출
            AudioManager.shared.startRecording()
            print("녹음 시작")
        } else if activityType == ShortcutsManager.Suggestion.settings.type {
            // AudioManager의 설정 보기 함수 호출 (추가 구현 필요)
            // AudioManager.shared.showSettings()
            print("설정 보기")
        }
        return true
    }
}
