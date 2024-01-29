//
//  OnboardingView.swift
//  woju
//
//  Created by 정민호 on 1/23/24.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @State private var userName: String = ""
    @State private var userID: UUID = UUID()
    @State private var isEmpty: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 100)
                
                Text("내 정보")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical, 42)
                
                VStack(spacing: 24) {
                    List {
                        Section(header: Text("유저 ID")) {
                            Text(userID.uuidString)
                                .cornerRadius(8)
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.5))
                                .textSelection(.enabled)

                        }
                        Section(header: Text("이름")) {
                            TextField("호출명을 입력하세요", text: $userName)
                                .padding()
                                .cornerRadius(8)
                        }
                    }
                    .background(.accent)
                    .scrollContentBackground(.hidden)
                    .cornerRadius(30)
                    .scrollDisabled(true)
                    .frame(height: 250, alignment:.center)

                    Spacer()

                    NavigationLink(destination: MainView()) {
                        Text("설정 완료")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        print(self.userName)
                        self.isFirstLaunch = false
                        saveUserInfo(self.userID, self.userName)
                    })
                    .buttonStyle(.borderedProminent)
                    .disabled(userName == "")
                }
            }
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func saveUserInfo(_ userID: UUID, _ userName: String) {
        let _userInfo = UserInfo(id: userID, name: userName)
        if let encodedData = try? JSONEncoder().encode(_userInfo) {
            UserDefaults.standard.set(encodedData, forKey: "userInfo")
        }
    }
    
    func loadUserInfo() -> UserInfo? {
        if let encodedData = UserDefaults.standard.data(forKey: "userInfo"),
           let userInfo = try? JSONDecoder().decode(UserInfo.self, from: encodedData) {
            return userInfo
        }
        return nil
    }
}

#Preview {
    OnboardingView(isFirstLaunch: true)
}
