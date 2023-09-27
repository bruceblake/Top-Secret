//
//  GroupPostAddContent.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/16/22.
//

import SwiftUI

struct GroupPostShowInfoView: View {
    @EnvironmentObject var userVM: UserViewModel
    var postID: String
    var body: some View {
        VStack{
            
            Button(action:{
                //delete post
                userVM.deletePost(postID: postID)
            },label:{
                Text("Delete Post")
                .fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
            })
        
        }
    }
}

