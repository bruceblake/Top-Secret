//
//  ShowAllUsersVotedView.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/4/22.
//

import SwiftUI

struct ShowAllUsersVotedView: View {
    @Binding var showUsers: Bool
    @Binding var poll: PollModel
    
    
    func getUserPollChoice(userID: String) -> String {
        for option in poll.pollOptions{
            if option.pickedUsersID?.contains(userID) ?? false{
                return option.choice ?? ""
            }
        }
        return ""
    }
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                Button(action:{
                    print("ID users: \(poll.usersAnsweredID?.count ?? 0)")
                    print("Real users: \(poll.usersAnswered?.count ?? 0)")
                },label:{
                Text("\(poll.question ?? " ")")
                })
                ForEach(poll.usersAnswered ?? [], id: \.id){ user in
                    Text("\(user.nickName ?? "") voted for \(getUserPollChoice(userID: user.id ?? ""))").foregroundColor(FOREGROUNDCOLOR)
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

