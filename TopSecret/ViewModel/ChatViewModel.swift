//
//  ChatViewModel.swift
//  TopSecret
//
//  Created by nathan frenzel on 9/9/21.
//

import Foundation
import Firebase
import SwiftUI
import Combine


class ChatViewModel : ObservableObject {
    @Published var userList : [User] = []
    @Published var usersTypingList : [User] = []
    @Published var usersIdlingList : [User] = []
    @Published var group : GroupModel = GroupModel()
    @Published var pushText : Bool = false

    var colors: [String] = ["green","red","blue","orange","purple","teal"]
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var chatRepository = ChatRepository()

    private var cancellables : Set<AnyCancellable> = []

    init(){
        chatRepository.$userList
            .assign(to: \.userList, on: self)
            .store(in: &cancellables)
        chatRepository.$usersTypingList
            .assign(to: \.usersTypingList, on: self)
            .store(in: &cancellables)
        chatRepository.$usersIdlingList
            .assign(to: \.usersIdlingList, on: self)
            .store(in: &cancellables)
        chatRepository.$group
            .assign(to: \.group, on: self)
            .store(in: &cancellables)
        chatRepository.$pushText
            .assign(to: \.pushText, on: self)
            .store(in: &cancellables)
    }


    func getUsersIDList(users: [User], completion: @escaping ([String]) -> () ){

        var ans : [String] = []

        ans = users.map({ i -> String in
            return i.id ?? ""
        })

         completion(ans)

    }

    func getUsersTypingList(chatID: String, groupID: String){
        chatRepository.getUsersTypingList(chatID: chatID, groupID: groupID)
    }

    func getUsersIdlingList(chatID: String, groupID: String){
        chatRepository.getUsersIdlingList(chatID: chatID, groupID: groupID)
    }

    func getUsers(usersID: [String]){
        chatRepository.getUsers(usersID: usersID)
    }


    func getGroup(groupID: String){
        chatRepository.getGroup(groupID: groupID)
    }

    func joinChat(chatID: String, userID: String, groupID: String){
        chatRepository.joinChat(chatID: chatID, userID: userID, groupID: groupID)
    }

    func createGroupChat(name: String, users: [String], groupID: String, chatID: String, profileImage: String){
        chatRepository.createGroupChat(name: name, users: users, groupID: groupID, chatID: chatID, profileImage: profileImage)
    }


    func createPersonalChat(user1: String, user2: String, completion: @escaping (ChatModel) -> ()) -> (){
        //check if user1 and then user2 order exists
        COLLECTION_PERSONAL_CHAT.whereField("users", isEqualTo: [user1,user2]).getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }

            let way1IsEmpty = snapshot!.isEmpty

            //check if user2 and then user1 order exists
            COLLECTION_PERSONAL_CHAT.whereField("users", isEqualTo: [user2,user1]).getDocuments { (snapshot2, err) in
                if err != nil {
                    print("ERROR")
                    return
                }
                let way2IsEmpty = snapshot2!.isEmpty

                if !way1IsEmpty{
                    //hasChat
                    print("Users already have a personal chat!")
                    for document in snapshot!.documents {
                        let data = document.data()
                        return completion(ChatModel(dictionary: data))
                    }
                }else if !way2IsEmpty{
                    //hasChat
                    print("Users already have a personal chat!")
                    for document in snapshot2!.documents {
                        let data = document.data()
                        return completion(ChatModel(dictionary: data))
                    }
                }else if way1IsEmpty && way2IsEmpty{

                    //does not have chat
                    print("Users do not have a personal chat!")
                    let id = UUID().uuidString

                    let data = ["users":[user1, user2],"id":id,"chatType":"personal","lastMessageID":"NO_MESSAGE"] as [String : Any]

                    let chat = ChatModel(dictionary: data)


                    COLLECTION_PERSONAL_CHAT.document(id).setData(data){ err in
                        if err != nil {
                            print("ERROR")
                            return

                        }
                    }

                    return completion(chat)
                }
            }

        }

    }



    func pickColor(chatID: String, picker: Int, userID: String, groupID: String){
        chatRepository.pickColor(chatID: chatID, picker: picker, userID: userID, groupID: groupID)
    }

    func leaveChat(chatID: String, userID: String, groupID: String){
        chatRepository.leaveChat(chatID: chatID, userID: userID, groupID: groupID)
    }



}



