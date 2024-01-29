//
//  DIManager.swift
//  woju
//
//  Created by 정민호 on 1/4/24.
//

import Foundation
import Combine
import ActivityKit

final class DIManager: ObservableObject {
    @Published var num: Int = 0
    private var cancellable: Set<AnyCancellable> = Set()
    private var activity: Activity<DynamicIslandWidgetAttributes>?
    
    func onLiveActivity() {
            // 앱이 live activity사용 가능한지여부
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attribute = DynamicIslandWidgetAttributes(name: WebSocketManager.shared.nowSessionName ?? "ERROR")
        
            // stateful한 값
            let state = DynamicIslandWidgetAttributes.ContentState(value: 0)
            do {
                self.activity = try Activity.request(attributes: attribute, contentState: state)
                timer()
            } catch {
                print(error)
            }
        }
    
    func offLiveActivity() {
        Task {
            // final dynamic content정의, 디폴트, 즉시종료, date후 종료 설정가능
            await activity?.end(nil, dismissalPolicy: .default)
            cancellable.removeAll()
        }
    }
    
    func timer() {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [self] _ in
                num += 1
                Task {
                    let newState = DynamicIslandWidgetAttributes.ContentState(value: num)
                    // 애플워치에서 동작
                    let alertConfiguration = AlertConfiguration(
                        title: "timer update",
                        body: "현재숫자: \(num)",
                        sound: .default
                    )
                    await activity?.update(using: newState, alertConfiguration: alertConfiguration)
                }
            }
            .store(in: &cancellable)
    }
}
