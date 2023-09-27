//
//  RegisterValidationViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/18/21.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI








class RegisterValidationViewModel : ObservableObject {
    @Published var emailErrorMessage = ""
    @Published var usernameErrorMessage = ""
    @Published var passwordErrorMessage = ""
    @Published var emailIsFormatted: Bool = false
    @Published var emailIsTaken: Bool = true
    @Published var usernameIsTaken:Bool = true
    @Published var usernameIsLongEnough:Bool = true
    @Published var usernameIsShortEnough:Bool = true
    @Published var username = ""
    @Published var nickName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var birthday : Date = Date()
    @Published var userProfileImage : UIImage = UIImage(named: "topbarlogo")!
    @Published var user : User?
    
    private var cancellables : Set<AnyCancellable> = []
    
    private static let predicatePassword = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z]).{6,}$")
    private static let predicateEmail = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}")
    
    
    
    
    init(){
        

        
        isUsernameTakenPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.usernameIsTaken, on: self)
            .store(in: &cancellables)
        
        isEmailTakenPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.emailIsTaken, on: self)
            .store(in: &cancellables)
        isEmailFormattedCorrectlyPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.emailIsFormatted, on: self)
            .store(in: &cancellables)
        
        
        isUsernameValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.usernameErrorMessage, on: self)
            .store(in: &cancellables)
        
        isUsernameLongEnoughPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.usernameIsLongEnough, on: self)
            .store(in: &cancellables)
        
        isUsernameShortEnoughPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.usernameIsShortEnough, on: self)
            .store(in: &cancellables)
        
        
        
        
        isEmailValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.emailErrorMessage, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.passwordErrorMessage, on: self)
            .store(in: &cancellables)
        
    }
    
    
    func changeNickname(userID: String, nickName: String){
        COLLECTION_USER.document(userID).updateData(["nickName":nickName])
    }
    
    
    func persistImageToStorage(userID: String, image: UIImage) {
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
    
    
    
    
    
    
    func checkEmail(email: String, completion: @escaping (Bool) -> ()) -> (){
        
        
        
        COLLECTION_USER.whereField("email", isEqualTo: email).getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(String(describing: err?.localizedDescription))")
                return
            }
            DispatchQueue.main.async {
                if snapshot!.isEmpty{
                    completion(true)
                }else{
                    completion(false)
                }
            }

        }
    }
    
    
    func checkUsername(username: String, completion: @escaping (Bool) -> ()) -> (){
        COLLECTION_USER.whereField("username", isEqualTo: username).getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(String(describing: err?.localizedDescription))")
                return
            }
            DispatchQueue.main.async {
                if snapshot!.isEmpty{
                    completion(true)
                }else{
                    completion(false)
                }
            }
            
        }
    }
    
    private var isEmailValidPublisher: AnyPublisher<String,Never>{
        Publishers.CombineLatest(isEmailTakenPublisher,isEmailFormattedCorrectlyPublisher)
            .map{ emailIsTaken, emailIsFormatted in
                
                if !emailIsTaken && emailIsFormatted {
                    return "valid!"
                }else if emailIsTaken{
                    return "Email is not available!"
                }else{
                    return "Email is not formatted correctly!"
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var isUsernameValidPublisher: AnyPublisher<String,Never>{
        Publishers.CombineLatest3(isUsernameTakenPublisher,isUsernameLongEnoughPublisher, isUsernameShortEnoughPublisher)
            .map{ usernameIsTaken, usernameIsLongEnough, usernameIsShortEnough in
                if !usernameIsTaken && usernameIsLongEnough && usernameIsShortEnough{
                    return "valid!"
                }else if usernameIsTaken{
                    return "Username is not available!"
                }else if !usernameIsShortEnough{
                    return "Username is too long, must be less than 16 letters"
                }else{
                    return "Username is not long enough, must be at least 4 letters"
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    private var isEmailFormattedCorrectlyPublisher: AnyPublisher<Bool,Never>{
        $email
            .removeDuplicates()
            .map{ email in
                return Self.predicateEmail.evaluate(with: email)
                
            }
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
    
    private var isEmailTakenPublisher: AnyPublisher<Bool,Never>{
        $email
            .removeDuplicates()
            .flatMap { email in
                return Future { promise in
                    self.checkEmail(email: email) { (available) in
                        promise(.success(available ? false : true))
                    }
                }
            }
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    private var isUsernameTakenPublisher: AnyPublisher<Bool,Never>{
        $username
            .removeDuplicates()
            .flatMap { username in
                return Future { promise in
                    self.checkUsername(username: username) { (available) in
                        promise(.success(available ? false : true))
                    }
                }
            }
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var isUsernameLongEnoughPublisher: AnyPublisher<Bool,Never> {
        $username
            .removeDuplicates()
            .map { username in
                return username.count >= 4
            }
            .eraseToAnyPublisher()
    }
    
    private var isUsernameShortEnoughPublisher: AnyPublisher<Bool,Never> {
        $username
            .removeDuplicates()
            .map { username in
                return username.count < 16
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<String, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                if Self.predicatePassword.evaluate(with: password) && password.count >= 6{
                    return "Password is valid!"
                }else{
                    return "Password is not strong enough, must be at least 6 characters long"
                }
            }
        
            .eraseToAnyPublisher()
    }
    
    
    
}

