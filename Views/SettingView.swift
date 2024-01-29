import SwiftUI

struct SettingView: View {
    @State var name: String
    @State private var isEditing = false
    @State private var showAlert = false

    @Binding var goIndex: MainView.Tab

    var body: some View {
        VStack {
            HStack {
                Text("")
                Spacer()
                Button(isEditing ? "저장" : "수정") {
                    isEditing.toggle()
                    // 수정 버튼을 눌렀을 때 저장하는 로직 추가
                    if !isEditing {
                        saveName()
                    }
                }
                .safeAreaPadding()
            }
            Form {
                Section(header: Text("호출명")) {
                    if isEditing {
                        TextField("자신의 호출명을 입력해주세요", text: $name)
                    } else {
                        Text(name).foregroundStyle(Color(.gray))
                    }
                }
            }
        }
        // Show alert if showAlert is true
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("오류"),
                message: Text("이름을 " + (self.name.isEmpty ? "공백으" : name) + "로 설정할 수 없습니다."),
                dismissButton: .default(Text("확인"))
            )
        }.onAppear() {
            self.name = loadUserName()
        }
    }

    // 호출명을 저장하는 함수
    func saveName() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.uppercased() == "ERROR" || trimmedName.isEmpty {
            // Show alert if the name is "ERROR" or empty
            showAlert = true
            isEditing = true
        } else {
            // Save the trimmed name if it's not "ERROR" or empty
            UserDefaults.standard.set(trimmedName, forKey: "settingName")
            FileManager.saveDataToDocumentDirectory(trimmedName, fileName: "myName.txt")

            // Save the user info using the previously defined function
            if let userID = loadUserInfo()?.id {
                saveUserInfo(userID, trimmedName)
            }
        }
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
    
    func loadUserName() -> String {
        if let name = loadUserInfo()?.name {
            return name
        }
        return "ERROR"
    }
}
