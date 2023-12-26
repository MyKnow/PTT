//
//  FocusManager.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import AppIntents

struct SoundVolumeFocusFilter: SetFocusFilterIntent {
    
    // title 속성 정의
    static var title: LocalizedStringResource = "Set Sound Volume"
    
    // Display Representation 정의
    var displayRepresentation: DisplayRepresentation {
        let subtitle = LocalizedStringResource("\(soundVolume)%")
        return DisplayRepresentation(title: Self.title, subtitle: subtitle)
    }

    
    // 매개 변수 정의
    @Parameter(title: "Sound Volume", default: 100)
    var soundVolume: Int
    
    // 현재 집중모드 필터 설정 값을 읽어오는 함수
    static func getCurrentFilterSettings() async throws -> SoundVolumeFocusFilter {
        do {
            // 현재 활성화된 집중모드 필터 가져오기
            let currentFilter = try await SoundVolumeFocusFilter.current
            
            // 가져온 필터 설정 값 반환
            return currentFilter
        } catch let error {
            // 필터를 가져오는 동안 에러가 발생하면 예외 처리
            print("Error loading current filter: \(error.localizedDescription)")
            throw error
        }
    }
    

    // Perform 함수 구현
    func perform() async throws -> some IntentResult {
        // Focus 변경 시 수행할 작업 구현
        // 예: 소리 크기에 따른 앱 동작 업데이트
        AudioManager.shared.setSoundVolume(soundVolume)
        
        return .result()
    }
}
