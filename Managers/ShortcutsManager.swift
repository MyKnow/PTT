//
//  ShortcutsManager.swift
//  woju
//
//  Created by 정민호 on 1/13/24.
//

import Foundation
import Intents

class ShortcutsManager {
    // Singleton 인스턴스
    public static let shared = ShortcutsManager()
    
    // 단축어의 유형을 정의하는 열거형
    public enum Suggestion: CaseIterable {
        case bookmark
        case settings
        
        // 단축어의 유형에 따라 식별자 반환
        var type: String {
            switch self {
            case .bookmark:
                return "myknow.woju.audioManager.record"
            case .settings:
                return "myknow.woju.audioManager.play"
            }
        }
        
        // 단축어의 유형에 따라 제목 반환
        var title: String {
            switch self {
            case .bookmark:
                return "북마크 실행"
            case .settings:
                return "설정"
            }
        }
        
        // 단축어의 유형에 따라 발화 구문 반환
        var invocationPhrase: String {
            switch self {
            case .bookmark:
                return "응 북마크 실행해"
            case .settings:
                return "설정 보여줘"
            }
        }
    }
    
    // 단축어를 설정하는 함수
    func setup() {
        // 단축어 배열 초기화
        var suggestions: [INShortcut] = []
        
        // 모든 단축어 유형에 대해 단축어를 생성하고 배열에 추가
        for suggestion in Suggestion.allCases {
            suggestions.append(makeSuggestion(suggestion: suggestion))
        }
        
        // 단축어 제안을 시스템에 설정
        INVoiceShortcutCenter.shared.setShortcutSuggestions(suggestions)
    }
    
    // 단일 단축어를 생성하는 함수
    private func makeSuggestion(suggestion: Suggestion) -> INShortcut {
        // NSUserActivity를 사용하여 단축어의 기본 속성 설정
        let activity = NSUserActivity(activityType: suggestion.type)
        activity.title = suggestion.title
        activity.suggestedInvocationPhrase = suggestion.invocationPhrase
        
        // 단축어를 생성하여 반환
        return INShortcut(userActivity: activity)
    }
}
