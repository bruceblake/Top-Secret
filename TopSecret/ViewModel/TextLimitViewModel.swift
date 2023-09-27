//
//  TextLimitViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/3/22.
//

import Foundation


class TextLimitViewModel : ObservableObject {
    
    var limit : Int
    
    init(limit: Int){
        self.limit  = limit
    }
    
    @Published var value : String = "" {
        didSet {
            if value.count > limit{
                value = String(value.prefix(limit))
            }
        }
    }
    
}
