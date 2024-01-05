//
//  SettingView.swift
//  woju
//
//  Created by 정민호 on 1/4/24.
//

import SwiftUI

struct SettingView: View {
    @State var tCount = 0
    @State var name = ""
    @State var age = ""
    @State var meetDate = Date()
    @State var gender = 0
    
    let genderType = ["연애", "업무", "기타"]
    
    var body: some View {
//        NavigationView {
            Form{
                Section(header: Text("호출명")) {
                    TextField("자신의 호출명을 입력해주세요", text: $name).keyboardType(.default)
                }
                Section(header: Text("성별")) {
                    Picker("성별", selection: $gender) {
                        ForEach(0 ..< genderType.count) {
                            Text("\(self.genderType[$0])")
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("기념일")) {
                    DatePicker(selection: $meetDate, in:...Date(), displayedComponents: .date) {
                        Text("첫만남을 선택하세요")
                    }
                }
//            }.navigationTitle("기록의 시작").navigationBarTitleDisplayMode(.automatic)
        }
    }
}

#Preview {
    SettingView()
}
