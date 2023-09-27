//
//  UserCoreDataViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/29/22.
//

import Foundation
import CoreData


class UserCoreDataViewModel : ObservableObject {
    
    let container : NSPersistentContainer
    @Published var savedUsers : [UserEntity] = []
    init(){
        container = NSPersistentContainer(name: "UsersCoreData")
        container.loadPersistentStores { description, err in
            if err != nil {
                print("ERROR")
            }
            
            
        }
        
        fetchUsers()
    }
    
    
    func fetchUsers(){
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        do {
        savedUsers = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching. \(error)")
        }
    }
    
    func addUser(user: User){
        let newUser = UserEntity(context: container.viewContext)
        newUser.id = user.id
        newUser.username = user.username
        saveData()
    }
    
    
    func deleteUser(indexSet: IndexSet){
        guard let index = indexSet.first else {return}
        let entity = savedUsers[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchUsers()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
}
