//
//  RecentSearchViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/5/22.
//

import Foundation
import SwiftUI
import Combine
import Firebase


class RecentSearchViewModel : ObservableObject {
    @Published var recentSearches: [String] = []
    @Published var showSeeAll: Bool = false
    let userDefaults = UserDefaults.standard
    
    init(){
        userDefaults.set([], forKey: "recentSearches")
    }
    
    func fetchSearches(completion: @escaping (Bool) -> ()) -> (){
        self.recentSearches = userDefaults.object(forKey: "recentSearches") as? [String] ?? []
        return completion(true)
    }
    
    func addToRecentSearches(searchText: String){
        recentSearches.append(searchText)
        userDefaults.set(recentSearches, forKey: "recentSearches")
    }
    
    func removeFromRecentSearches(searchText: String){
        recentSearches.removeAll { search in
            return search == searchText
        }
        userDefaults.set(recentSearches, forKey: "recentSearches")

    }

    
}
