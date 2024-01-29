//
//  JoinView.swift
//  woju
//
//  Created by 정민호 on 12/23/23.
//

import SwiftUI

struct SessionInfo: Codable {
    var isOneToOne: Bool = false
    var sessionId: String
    var sessionName: String
//    var sessionPwd: String?
}

struct MySession: Codable {
    var isFavorite: Bool = false
    var Session : SessionInfo
}

struct JoinView: View {
    @StateObject var viewModel = DIManager()
    @State private var isFullAlertVisible = false
    @State private var isSearchPopupVisible = false
    @State private var isPlusPopupVisible = false
    @State private var selectedSession: String = ""
    @State private var sessionList: [MySession] = FileManager.loadDataFromDocumentDirectory("myChannel.json", as: [MySession].self) ?? []
    
    @Binding var goIndex:MainView.Tab

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isSearchPopupVisible.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .padding()
                .sheet(isPresented: $isSearchPopupVisible) {
                    SearchSheetView(isSearchPopupVisible: $isSearchPopupVisible, sessionList: $sessionList)
                }

                Spacer()

                Button(action: {
                    self.isPlusPopupVisible.toggle()
                }) {
                    Image(systemName: "plus")
                }
                .padding()
                .sheet(isPresented: $isPlusPopupVisible) {
                    PlusSheetView(isPlusPopupVisible: $isPlusPopupVisible, sessionList: $sessionList)
                }
            }
            
            List {
                ForEach(sessionList.indices, id: \.self) { index in
                    let mysession = sessionList[index]
                    let session = mysession.Session

                    HStack {
                        Button(action: {
                            if self.selectedSession == session.sessionId {
                                print("JOIN")
                                self.goIndex = .recording
                            } else {
                                self.selectedSession = session.sessionId
                                HapticManager.shared.vibrate()
                                print(selectedSession)
                                
                                Task {
                                    // 비동기적으로 setSession 함수 호출
                                    let result = await WebSocketManager.shared.setSession(selectedSession, session.sessionName)

                                    // setSession 함수의 반환값을 확인하여 조건에 따라 동작 수행
                                    switch result {
                                    case "JOIN":
                                        // 성공적으로 join한 경우
                                        print("JOIN")
                                        self.goIndex = .recording
            //                            viewModel.onLiveActivity()
                                        
                                    case "FAIL":
                                        // JOIN 실패한 경우
                                        print("JOIN FAILURE")
                                        self.isFullAlertVisible = true

                                        // 실패에 대한 처리 코드 작성
                                    default:
                                        print("ERROR")
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: session.isOneToOne ? "person.wave.2.fill" : "person.2.wave.2.fill")
                                Text(session.sessionName)
                                Spacer()
                            }
                        }
                        .contextMenu {
                            Button("공유") {
                                infoSession(mysession)
                            }
                            Button("정보") {
                                shareSession(mysession)
                            }
                        }

                        Button(action: {
                        }) {
                            Image(systemName: mysession.isFavorite ? "star.fill" : "star")
                        }
                        .padding(.trailing, 10)
                        .onTapGesture {
                            self.sessionList[index].isFavorite.toggle()
                            self.sessionList.sort { $0.isFavorite && !$1.isFavorite }
                        }
                    }
                    .listRowBackground(self.selectedSession == session.sessionId ? Color.red.opacity(0.1) : Color.white)
                }
                .onDelete(perform: deleteSession)
                .alert(isPresented: $isFullAlertVisible) {
                    Alert(title: Text("입장 실패"), message: Text("세션이 가득 차서 입장할 수 없습니다."), dismissButton: .default(Text("확인")))
                }
            }
        }
        .onAppear {
            // Load the sessionList from the device's internal storage
            if let loadedSessionList: [MySession] = FileManager.loadDataFromDocumentDirectory("myChannel.json", as: [MySession].self) {
                self.sessionList = loadedSessionList
            } else {
                // Use the default sessionList if loading fails
                print("no files")
                self.sessionList = []
            }

            self.sessionList.sort { $0.isFavorite && !$1.isFavorite }
        }
    }

    func deleteSession(at offsets: IndexSet) {
        // 파일에서 해당 요소를 제거합니다.
        var existingData = FileManager.loadDataFromDocumentDirectory("myChannel.json", as: [MySession].self) ?? []
        
        // 지정된 세션에서 leave
        let deletedSessionID = existingData[offsets.first!].Session.sessionId
        
        if WebSocketManager.shared.nowSessionID == deletedSessionID {
            WebSocketManager.shared.leaveNowSession()
        }

        // 해당 인덱스의 데이터를 삭제
        existingData.remove(atOffsets: offsets)

        // 파일에 업데이트된 데이터 저장
        FileManager.saveDataToDocumentDirectory(existingData, fileName: "myChannel.json")
        

        // 리스트를 업데이트합니다.
        sessionList = existingData
    }


    func infoSession(_ session: MySession) {
        print("TEST")
    }
    
    func shareSession(_ session: MySession) {
        //ShareLink(item: "TEST")
    }
}

//struct JoinView_Previews: PreviewProvider {
//    static var previews: some View {
//        JoinView()
//    }
//}

// SheetView의 코드를 수정하여 파일에 요소를 추가하도록 변경합니다.
struct PlusSheetView: View {
    @Binding var isPlusPopupVisible: Bool
    
    @State private var randomString = ""
    @State private var name = ""
    @State private var isSecret = false
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showToast = false
    @State private var toastMessage = ""

    let options = ["1:1", "1:N"]
    @State private var selectedOption = 0
    @Binding var sessionList: [MySession]
    
    var server = ServerManager()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("채널 ID")) {
                    Text(randomString)
                        .foregroundColor(.gray)
                        .onAppear {
                            randomString = generateRandomString(length: 4)
                        }
                }
                Section(header: Text("채널 타입")) {
                    Picker("Options", selection: $selectedOption) {
                        ForEach(0..<options.count) {
                            Text(options[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedOption) {
                        randomString = generateRandomString(length: 4)
                    }
                }

                Section(header: Text("채널 이름")) {
                    TextField("채널의 이름을 입력하세요", text: $name).keyboardType(.default)
                }

//                Section(header: Text("비밀 채널")) {
//                    Toggle("비밀번호 설정", isOn: $isSecret)
//
//                    if isSecret {
//                        Group {
//                            if isPasswordVisible {
//                                TextField("비밀번호 입력", text: $password).keyboardType(.alphabet)
//                            }else {
//                                SecureField("비밀번호 입력", text: $password).keyboardType(.alphabet)
//                            }
//                        }
//                        .overlay(
//                            HStack {
//                                Spacer()
//                                Button(action: {
//                                    isPasswordVisible.toggle()
//                                }) {
//                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                        )
//                    }
//                }
            }
            .navigationBarTitle("채널 생성")
            .navigationBarItems(
                trailing: HStack {
                    Button("취소") {
                        isPlusPopupVisible = false
                    }
                    Button("생성") {
                        if !name.isEmpty || (isSecret && password.isEmpty) {
                            let sessionInfo = SessionInfo(
                                isOneToOne: selectedOption == 0,
                                sessionId: randomString,
                                sessionName: name
//                               , sessionPwd: isSecret ? password : nil
                            )
                            
                            server.createSession(sessionInfo)
                            
                            let mysession = MySession(
                                isFavorite: false, Session: sessionInfo
                            )
                            
                            // 파일에 요소를 추가합니다.
                            var existingData = FileManager.loadDataFromDocumentDirectory("myChannel.json", as: [MySession].self) ?? []
                            existingData.append(mysession)
                            FileManager.saveDataToDocumentDirectory(existingData, fileName: "myChannel.json")
                            
                            // 리스트를 업데이트합니다.
                            sessionList = existingData

                            isPlusPopupVisible = false
                        } else {
                            // 적절한 오류 처리 로직을 추가하세요.
                        }
                    }

                }
            )
        }
        .padding()
    }

    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String(Int(Date().timeIntervalSince1970)*10%100000)+(selectedOption==0 ? "O" : "N")+String((0..<length).map { _ in letters.randomElement()! })
    }
}

struct SearchSheetView: View {
    @Binding var isSearchPopupVisible: Bool
    
    @State private var channelID = ""
    @State private var name = ""
    @State private var isSecret = false
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isFound = false

    let options = ["1:1", "1:N"]
    @State private var selectedOption = 0
    @Binding var sessionList: [MySession]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("채널 ID")) {
                    HStack {
                        TextField("채널의 아이디를 입력하세요", text: $channelID).keyboardType(.alphabet)
                        Button(action: {
                            if channelID.count == 9 {
                                isFound = true
                                if channelID[channelID.index(channelID.startIndex, offsetBy: 4)] == "N" {
                                    selectedOption = 1
                                } else if channelID[channelID.index(channelID.startIndex, offsetBy: 4)] == "O" {
                                    selectedOption = 0
                                } else {
                                    isFound = false
                                }
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .accentColor(.gray)
                        }
                        .frame(width: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/)
                    }
                }
                
                if isFound {
                    Section(header: Text("채널 타입")) {
                        Picker("Options", selection: $selectedOption) {
                            ForEach(0..<options.count) {
                                Text(options[$0])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .disabled(true) // 비활성화하려면 true를 사용하고, 활성화하려면 false를 사용합니다.
                    }

                    Section(header: Text("채널 이름")) {
                        // 테스트
                        TextField("채널의 이름을 설정해주세요", text: $name)
                    }

//                    Section(header: Text("비밀 채널")) {
//                        Toggle("비밀번호 설정", isOn: $isSecret)
//
//                        if isSecret {
//                            Group {
//                                if isPasswordVisible {
//                                    TextField("비밀번호 입력", text: $password).keyboardType(.alphabet)
//                                }else {
//                                    SecureField("비밀번호 입력", text: $password).keyboardType(.alphabet)
//                                }
//                            }
//                            .overlay(
//                                HStack {
//                                    Spacer()
//                                    Button(action: {
//                                        isPasswordVisible.toggle()
//                                    }) {
//                                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                            )
//                        }
//                    }
                }
            }
            .navigationBarTitle("채널 찾기")
            .navigationBarItems(
                trailing: HStack {
                    Button("취소") {
                        isSearchPopupVisible = false
                    }
                    if isFound {
                        Button("참가") {
//                            if !name.isEmpty {
                            if true {
                                let sessionInfo = SessionInfo(
                                    isOneToOne: selectedOption == 0,
                                    sessionId: channelID,
                                    sessionName: name
//                                    ,sessionPwd: isSecret ? password : nil
                                )
                                
                                let mysession = MySession(
                                    isFavorite: false, Session: sessionInfo
                                )
                                
                                // 파일에 요소를 추가합니다.
                                var existingData = FileManager.loadDataFromDocumentDirectory("myChannel.json", as: [MySession].self) ?? []
                                existingData.append(mysession)
                                FileManager.saveDataToDocumentDirectory(existingData, fileName: "myChannel.json")
                                
                                // 리스트를 업데이트합니다.
                                sessionList = existingData

                                isSearchPopupVisible = false
                            } else {
                                // 적절한 오류 처리 로직을 추가하세요.
                                print("NoName or PWD Error")
                            }
                        }
                    }
                }
            )
        }
        .padding()
    }
}
