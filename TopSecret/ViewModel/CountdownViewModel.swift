//
//  CountdownViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/6/22.
//

import Foundation


class CountdownViewModel : ObservableObject {
    
    func fetchCountdown(groupID: String, countdownID: String, completion: @escaping (CountdownModel) -> () ) -> (){
        COLLECTION_GROUP.document(groupID).collection("Countdowns").document(countdownID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(CountdownModel(dictionary: data ?? [:]))
            
        }
    }
}
