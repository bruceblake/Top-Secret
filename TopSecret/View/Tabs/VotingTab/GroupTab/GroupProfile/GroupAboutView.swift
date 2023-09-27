//
//  GroupAboutView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/21/22.
//

import SwiftUI

struct GroupAboutView: View {
     var group: GroupModel
    @StateObject var groupVM = GroupViewModel()
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        ZStack{
            
            
        VStack{
            VStack{
                HStack{
                    Text("Bio")
                    
                    Button(action:{
                        
                    },label:{
                        Text("Edit")
                    })
              
                }
                Text("\(group.bio ?? "")")
            }
        }
            
            
        
    }
    }
}

//struct GroupAboutView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupAboutView()
//    }
//}
