//
//  HapticManager.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import CoreHaptics

class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?

    private init() {
        setupHaptics()
    }

    // Core Haptics 엔진 초기화
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

        } catch {
            print("Error initializing haptic engine: \(error.localizedDescription)")
        }
    }

    // 진동 발생 함수
    func vibrate() {
        guard let engine = engine else {
            return
        }

        do {
            // 진동 이벤트 생성
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.5)
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])

            // 진동 이벤트를 엔진에 전달
            try engine.makePlayer(with: pattern).start(atTime: 0)
            
        } catch {
            print("Error playing haptic event: \(error.localizedDescription)")
        }
    }
}
