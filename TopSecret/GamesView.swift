//
//  GamesView.swift
//  Top Secret
//
//  Created by Bruce Blake on 2/2/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI




struct GamesView: View {
   

    @State private var openGame1 = false
    @State private var openGame2 = false
    
    var body: some View {
        
        
        
        ZStack{
            Color("Background")
                
            VStack{
                
                Button(action:{
                    self.openGame1.toggle()
                },label:{
                    Text("Game 1")
                })
               
                
                Button(action:{
                    self.openGame2.toggle()
                },label:{
                    Text("Game 2")
                })
               

            }
            
            NavigationLink(destination: QuestionsLobbyView(openGame1: $openGame1), isActive: $openGame1) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct QuestionsLobbyView : View {
    
    @ObservedObject var lobbyVM = LobbyViewModel()
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var questions: [Question] = [Question()]
    var questionsLimit : Int = 5
    @State var keyboardHeight : CGFloat = 0
    @Binding var openGame1 : Bool
    @Environment(\.scenePhase) var scenePhase
    @State var game : Game = Game()
    
    
    func addQuestion(){
        questions.append(Question())
    }
    
    func checkIfReady(playerID: String) -> Bool {
        if playerID == userVM.user?.id ?? "" {
            return lobbyVM.lobby.playersReady.contains(playerID) && questions.filter({return $0.saved}).count >= 3
        }else{
            return lobbyVM.lobby.playersReady.contains(playerID)
        }
    }
    
    func initKeyboardGuardian(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { data in
            let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            
            self.keyboardHeight = height1.cgRectValue.height - 20
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    
    func getForegroundColor(hasThreeQuestionsSaved: Bool, isReady: Bool) -> Color {
        if !hasThreeQuestionsSaved {
            return Color.black
        }else if hasThreeQuestionsSaved && isReady{
            return Color("AccentColor")
        }else if hasThreeQuestionsSaved && !isReady{
            return FOREGROUNDCOLOR
        }else{
            return Color.clear
        }
    }
    
    func getBackgroundColor(hasThreeQuestionsSaved: Bool, isReady: Bool) -> Color {
        if !hasThreeQuestionsSaved{
            return Color.gray
        }else if hasThreeQuestionsSaved && isReady{
            return Color("Background")
        }else if hasThreeQuestionsSaved && !isReady{
            return Color("AccentColor")
        }else{
            return Color.clear
        }
    }
    var body: some View {
        ZStack{
            NavigationLink(destination: QuestionsGameView(lobbyVM: lobbyVM, questions: questions, gameID: self.game.id), isActive: $lobbyVM.everyoneIsReady) {
                EmptyView()
            }
            Color("Background")
            VStack{
                
                
                HStack{
                    Button(action:{
                        self.openGame1.toggle()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Question Game").font(.title3)
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                VStack{
                    HStack(alignment: .top){
                        Spacer()
                        Text("\(lobbyVM.lobby.playersReady.count) out of \(groupVM.group.users.count) members are ready")
                        Spacer()
                    }
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(lobbyVM.lobby.players){ player in
                                VStack(spacing: 3){
                                    WebImage(url: URL(string: player.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                        .overlay{
                                            
                                            
                                            if  self.checkIfReady(playerID: player.id ?? " "){
                                                Circle().stroke(Color.green, lineWidth: 3)
                                                
                                                
                                                
                                            }else{
                                                Circle().stroke(Color.red, lineWidth: 3)
                                            }
                                            
                                            
                                        }
                                    Text("\(player.nickName ?? "")").font(.caption)
                                }
                            }
                        }
                        
                        
                    }
                    Divider()
                    VStack(spacing: 15){
                        
                        ScrollView(showsIndicators: false){
                            VStack{
                                ForEach(0..<questions.count, id: \.self) { index in
                                    
                                    VStack(alignment: .leading, spacing: 5){
                                        
                                        Text("Question \(index + 1)")
                                        
                                        if questions[index].saved{
                                            HStack{
                                                Text(questions[index].question).foregroundColor(Color.gray)
                                                Spacer()
                                            }
                                        }else{
                                            HStack{
                                                TextField("Enter Question", text: self.$questions[index].question).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                                                
                                                Button(action:{
                                                    questions[index].saved = true
                                                    if questions.count < 5 {
                                                        withAnimation{
                                                            self.addQuestion()
                                                        }
                                                    }
                                                    
                                                },label:{
                                                    Text("Save")
                                                })
                                            }
                                            
                                        }
                                    }.padding(.vertical,10)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text("• Must save atleast 3 questions")
                        Text("• Ask questions like: most likely to jump off a bridge ")
                        Text("• Once a majority of players join, the game will start")
                    }.foregroundColor(Color.gray)
                    
                    Button(action:{
                        if self.checkIfReady(playerID: userVM.user?.id ?? " "){
                            lobbyVM.indicateNotReady(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id)
                        }else{
                            lobbyVM.indicateReady(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id, questions: questions)
                        }
                    },label:{
                        
                        Text("\(self.checkIfReady(playerID: userVM.user?.id ?? " ") ? "Unjoin Game" : "Join Game")  ").foregroundColor(self.getForegroundColor(hasThreeQuestionsSaved: questions.filter({ return $0.saved == true}).count >= 3, isReady: self.checkIfReady(playerID: userVM.user?.id ?? " "))).padding(.vertical,10)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(self.getBackgroundColor(hasThreeQuestionsSaved: questions.filter({ return $0.saved == true}).count >= 3, isReady: self.checkIfReady(playerID: userVM.user?.id ?? " "))).cornerRadius(15)
                        
                        
                    }).disabled(questions.filter({ return $0.saved == true}).count < 3).padding()
                    
                    HStack{
                        Text("\(questions.filter({ return $0.saved == true}).count)/\(questionsLimit) questions saved").foregroundColor(questions.filter({ return $0.saved == true}).count >= 3 ? Color.green : Color.red)
                        Spacer()
                    }
                }
                .padding().background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            self.initKeyboardGuardian()
            lobbyVM.fetchLobby(groupID: groupVM.group.id)
            lobbyVM.enterLobby(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id)
        }.onDisappear{
            if !lobbyVM.lobby.everyoneIsReady{
                lobbyVM.exitLobby(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id)
            }
            
        }.onChange(of: scenePhase){ newPhase in
            if newPhase == .active{
                lobbyVM.enterLobby(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id)
            }else if newPhase == .background{
                lobbyVM.exitLobby(playerID: userVM.user?.id ?? " ", groupID: groupVM.group.id)
            }
        }.onReceive(lobbyVM.$everyoneIsReady) { output in
            lobbyVM.startGame(groupID: groupVM.group.id, players: lobbyVM.lobby.playersReady, questions: questions) { fetchedGame in
                self.game = fetchedGame
            }
        }
    }
}

class LobbyViewModel : ObservableObject {
    
    //step by step:
    //1. when player enters into group homescreen, place them in lobby
    
    
    //2. allow players to enter into a game
    //3. upon requirements of game, allow players to ready up (all must be ready)
    
    //4. once all players are ready, game will start; players removed from lobby; game instantiated and players entered into game
    
    
    @Published var lobby : Lobby = Lobby()
    @Published var everyoneIsReady: Bool = false
    
    func indicateReady(playerID: String, groupID: String, questions: [Question]){
        
        COLLECTION_GAMES.document(groupID).collection("Lobby").document("Lobby").updateData(["playersReady":FieldValue.arrayUnion([playerID])])
      
    }
    
    func indicateNotReady(playerID: String, groupID: String){
        COLLECTION_GAMES.document(groupID).collection("Lobby").document("Lobby").updateData(["playersReady":FieldValue.arrayRemove([playerID])])
    }
    
    func enterLobby(playerID: String, groupID: String){
        COLLECTION_GAMES.document(groupID).collection("Lobby").document("Lobby").updateData(["playersID":FieldValue.arrayUnion([playerID])])
    }
    
    func exitLobby(playerID: String, groupID: String){
        COLLECTION_GAMES.document(groupID).collection("Lobby").document("Lobby").updateData(["playersID":FieldValue.arrayRemove([playerID])])
        self.indicateNotReady(playerID: playerID, groupID: groupID)
    }
    
    
    func fetchLobby(groupID: String) {
        COLLECTION_GAMES.document(groupID).collection("Lobby").document("Lobby").addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var playersReady = data["playersReady"] as? [String] ?? []
            var playersID = data["playersID"] as? [String] ?? []
            var playersFetched : [User] = []
            let dp = DispatchGroup()
            
            dp.enter()
            self.fetchUsers(users: playersID) { fetchedPlayers in
                data["players"] = fetchedPlayers
                playersFetched = fetchedPlayers
                print("fetched players")
                dp.leave()
            }
           
            
          
            
            dp.notify(queue: .main, execute: {
                self.lobby = Lobby(dictionary: data)
                if ((playersFetched.count != 0 && playersReady.count != 0 ) &&  playersReady.count == playersFetched.count){
                    //UPDATE LOBBY THAT EVERYONE IS READY
                    if !self.lobby.everyoneIsReady{
                        COLLECTION_GAMES.document(groupID).collection("Lobby").document("Lobby").updateData(["everyoneIsReady":true])
                        self.everyoneIsReady = true
                    }
                  
                    
                }
            })
            
        }
    }
    
    
    func startGame(groupID: String, players: [String], questions: [Question], completion: @escaping (Game) -> ()) -> (){
        let gameID = UUID().uuidString
        var gameData = [
            "playersID":players,"id":gameID,"timeStarted":Timestamp()] as? [String:Any] ?? [:]
        COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).setData(gameData)
        for question in questions {
            var questionData = ["id":question.id,
                                "question":question.question,
                                "totalUsersThatHaveChosen":question.totalUsersThatHaveChosen
            ] as? [String:Any] ?? [:]
            COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).collection("Questions").document(question.id).setData(questionData)
        }
        return completion(Game(dictionary: gameData))
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



class GameViewModel : ObservableObject {
    @Published var game: Game = Game()
    @Published var lobby: Lobby = Lobby()
    @Published var gameHasStarted : Bool = false
    //when user goes to screen; show idling in lobby; until they join the game
    //once 3 players join the game then ready up
    //

    
    func voteOnQuestion(playerID: String, groupID: String, gameID: String, questionID: String, choiceID: String){
        COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).collection("Questions").document(questionID).updateData(["totalUsersThatHaveChosen":FieldValue.arrayUnion([playerID])])
        COLLECTION_GAMES.document(groupID).collection("Games").document(gameID).collection("Questions").document(questionID).collection("Options").document(choiceID).updateData(["usersThatHaveChosen":FieldValue.arrayUnion([playerID])])
    }
    
}


struct Question : Identifiable{
    var id: String = UUID().uuidString
    var question: String
    var saved: Bool
    var answerChoices: [AnswerChoice]?
    var totalUsersThatHaveChosen : [String]
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.question = dictionary["question"] as? String ?? ""
        self.totalUsersThatHaveChosen = dictionary["totalUsersThatHaveChosen"] as? [String] ?? []
        self.saved = dictionary["saved"] as? Bool ?? false
    }
    
    init(){
        self.question = ""
        self.totalUsersThatHaveChosen = []
        self.saved = false
    }
}

struct AnswerChoice : Identifiable{
    var id: String = ""
    var choice: String
    var usersThatHaveChosen : [String]
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.choice = dictionary["choice"] as? String ?? ""
        self.usersThatHaveChosen = dictionary["usersThatHaveChosen"] as? [String] ?? []
    }
}

struct Lobby {
    var playersReady: [String]
    var players: [User]
    var playersID: [String]
    var everyoneIsReady: Bool
    
    init(dictionary: [String:Any]){
        self.playersReady = dictionary["playersReady"] as? [String] ?? []
        self.players = dictionary["players"] as? [User] ?? []
        self.playersID = dictionary["playersID"] as? [String] ?? []
        self.everyoneIsReady = dictionary["everyoneIsReady"] as? Bool ?? false
    }
    
    init(){
        self.players = []
        self.playersID = []
        self.playersReady = []
        self.everyoneIsReady = false
    }
}

struct Game: Identifiable{
    var id: String = ""
    var playersID: [String]
    var players: [User]
    var groupID: String
    var questions: [String]
    var timeStarted: Timestamp
    
    
    init(dictionary: [String:Any]){
        self.playersID = dictionary["playersID"] as? [String] ?? []
        self.players = dictionary["players"] as? [User] ?? []
        self.questions = dictionary["questions"] as? [String] ?? []
        self.id = dictionary["id"] as? String ?? ""
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.timeStarted = dictionary["timeStarted"] as? Timestamp ?? Timestamp()
    }
    
    init(){
        self.playersID = []
        self.players = []
        self.questions = []
        self.timeStarted = Timestamp()
        self.groupID = UUID().uuidString
    }
    
    
}

