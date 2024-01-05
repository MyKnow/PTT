//
//  JoinView.swift
//  woju
//
//  Created by 정민호 on 12/23/23.
//

import SwiftUI

struct SessionInfo {
    var isFavorite: Bool = false
    var isOneToOne: Bool = false
    var sessionId: String
    var sessionName: String
}

struct JoinView: View {
    @State private var isSearchPopupVisible = false
    @State private var isPlusPopupVisible = false
    @State private var selectedSession: String? = nil
    @State private var sessionList: [SessionInfo] = [
        SessionInfo(sessionId: "Session 1", sessionName: "여자친구"),
        SessionInfo(sessionId: "Session 2", sessionName: "회사"),
        SessionInfo(sessionId: "Session 3", sessionName: "작업장")
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isSearchPopupVisible.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
                .padding()

                Spacer()

                Button(action: {
                    self.isPlusPopupVisible.toggle()
                }) {
                    Image(systemName: "plus")
                }
                .padding()
            }
            
            List(sessionList.indices, id: \.self) { index in
                let session = sessionList[index]

                HStack {
                    Button(action: {
                        self.selectedSession = session.sessionId
                    }) {
                        HStack {
                            Image(systemName: session.isOneToOne ? "person.2.fill" : "person.2.wave.2.fill")
                            Text(session.sessionName)
                        }
                    }

                    Spacer()

                    Button(action: {
                        self.sessionList[index].isFavorite.toggle()
                        self.sessionList.sort { $0.isFavorite && !$1.isFavorite }
                    }) {
                        Image(systemName: session.isFavorite ? "star.fill" : "star")
                    }
                    .padding(.trailing, 10)
                }
            }
        }
    }
}

struct JoinView_Previews: PreviewProvider {
    static var previews: some View {
        JoinView()
    }
}
