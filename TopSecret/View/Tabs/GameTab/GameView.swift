//
//  GameView.swift
//  TopSecret
//
//  Created by Bruce Blake on 3/1/22.
//

import SwiftUI
import Firebase

struct QuestionsGameView: View {
   
    @ObservedObject var gameVM = QuestionsGameViewModel()
    @ObservedObject var lobbyVM: LobbyViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    var questions: [Question]
    var gameID: String
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .top){
                    Spacer()
                    Button(action:{
                        gameVM.leaveGame(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id, gameID: gameID)
                    },label:{
                        Text("Leave Game")
                    })
                    Spacer()
                }
                Text(gameID)
                ForEach(lobbyVM.lobby.players){ player in
                    Text("\(player.username ?? " ")")
                }
                
            }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
        }
    }
}

class QuestionsGameViewModel : ObservableObject {
    @Published var game : Game = Game()
    
    

    
    
    
    
    func joinGame(playerID: String, groupID: String, gameID: String){
        COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).updateData(["playersID":FieldValue.arrayUnion([playerID])])
    }
    
    func leaveGame(playerID: String, groupID: String, gameID: String){
        COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).updateData(["playersID":FieldValue.arrayRemove([playerID])])
    }
    
    
    func fetchGame(groupID: String, gameID: String)  {
        COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var playersID = data["playersID"] as? [String] ?? []
            let dp = DispatchGroup()
            
            dp.enter()
            self.fetchUsers(users: playersID) { fetchedPlayers in
                data["players"] = fetchedPlayers
                print("fetched players")
                dp.leave()
            }
            
            dp.notify(queue: .main, execute: {
                self.game = Game(dictionary: data)
            })
        }
    }
    
   
    
    func fetchUsers(users: [String], completion: @escaping ([User]) -> ()) -> () {
        let dp = DispatchGroup()
        var usersToReturn : [User] = []
        for user in users {
            dp.enter()
            COLLECTION_USER.document(user).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                dp.leave()
            }
        }
        dp.notify(queue: .main, execute:{
            return completion(usersToReturn)
        })
    }
}

