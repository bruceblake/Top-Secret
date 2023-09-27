//
//  UserEditProfileViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/3/22.
//

import Foundation
import Combine
import Firebase
import SwiftUI
import FirebaseStorage



class UserEditProfileViewModel : ObservableObject {
    @Published var username = ""
    @Published var bio = ""
    @Published var nickname = ""
    @Published var didChangeUsername : Bool = false
    @Published var didChangeBio : Bool = false
    @Published var didChangeNickName : Bool = false
    @Published var didChangeProfilePicture : Bool = false
    @Published var saving: Bool = false
    
    
    init(){
        
    }
    
    
    func changeUsername(userID: String, username: String){
        COLLECTION_USER.document(userID).updateData(["username":username])
    }
    
    func changeBio(userID: String, bio: String){
        
        COLLECTION_USER.document(userID).updateData(["bio":bio])
    }
    
    
    
    func changeNickname(userID: String, nickName: String){
        COLLECTION_USER.document(userID).updateData(["nickName":nickName])
    }
    
    
    func changeProfilePicture(userID: String, image: UIImage){
        let fileName = "userProfileImages/\(userID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return
            }
            ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                COLLECTION_USER.document(userID).updateData(["profilePicture":imageURL])
            }
        }
        
    }
    
    
  
}
