//
//  HomeScreenViewModel.swift
//  TopSecret
//
//  Created by nathan frenzel on 9/5/21.
//

import Foundation
import Firebase

class HomeScreenViewModel : ObservableObject {
  @Published var users = [User]()
    
    init(){
        fetchUsers()
    }
    
    func fetchUsers(){
        COLLECTION_USER.getDocuments { (snapshot, _) in
            guard let documents = snapshot?.documents else {return}
            self.users = documents.map({User(dictionary: $0.data())})
        }
    }
   
}
