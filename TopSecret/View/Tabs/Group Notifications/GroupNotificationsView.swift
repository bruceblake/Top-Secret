//
//  GroupNotificationsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/14/22.
//

import SwiftUI

struct GroupNotificationsView: View {
    
    @Binding var group : GroupModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel

    var body: some View {
        ZStack{
        Color("Background")
            
            VStack{
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}


