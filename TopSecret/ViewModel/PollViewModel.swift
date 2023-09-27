import Firebase
import Foundation


class PollViewModel : ObservableObject {
    
    
    @Published var poll : PollModel = PollModel()
    
    
    func fetchPoll(groupID: String, pollID: String, completion: @escaping (PollModel) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            groupD.enter()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            self.fetchUsersAnswered(usersID: data["usersAnsweredID"] as? [String] ?? []) { fetchedUsers in
                data["usersAnswered"] = fetchedUsers
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchPollOptions(pollID: data["id"] as? String ?? " ", groupID: groupID) { fetchedChoices in
                data["pollOptions"] = fetchedChoices
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchUser(userID: data["creatorID"] as? String ?? " ") { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            
            groupD.notify(queue: .main) {
                self.poll = PollModel(dictionary: data)
                return completion(PollModel(dictionary: data))
            }
            
        }
    }
    
    func fetchUsersAnswered(usersID: [String], completion: @escaping ([User]) -> ()) -> () {
        var usersToReturn : [User] = []
        let groupD = DispatchGroup()
        groupD.enter()
        for userID in usersID{
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                
                usersToReturn.append(User(dictionary: data))
                
            }
        }
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    func fetchPollOptions(pollID: String, groupID: String, completion: @escaping ([PollOptionModel]) -> () ) -> () {
        var choicesToReturn : [PollOptionModel] = []

        COLLECTION_GROUP.document(groupID).collection("Polls").document(pollID).collection("Options").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
              
                
                    choicesToReturn.append(PollOptionModel(dictionary: data))
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(choicesToReturn)
            })
            
            
        }
    }
    
}
