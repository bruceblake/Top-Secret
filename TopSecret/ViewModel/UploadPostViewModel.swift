//
//  UploadPostViewModel.swift
//  TopSecret
//
//  Created by nathan frenzel on 9/5/21.
//

import SwiftUI
import Firebase

class UploadPostViewModel: ObservableObject {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel = HomeScreenViewModel()
    
    @EnvironmentObject var vm : UserViewModel
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    func uploadPost(caption: String, groupName: String) {
        guard let user =  vm.user else { return }
        let docRef = COLLECTION_POSTS.document()
        
        let data: [String: Any] = ["uid": user.id,
                                   "caption": caption,
                                   "fullname": user.nickName,
                                   "timestamp": Timestamp(date: Date()),
                                   "username": user.username,
                                   "groupname": groupName,
                                   "likes": 0,
                                   "id": docRef.documentID  ]
        
        docRef.setData(data) { _ in
            print("DEBUG: Successfully uploaded tweet..")
            self.isPresented = false
        }
    }
}


