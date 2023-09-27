//
//  GroupPostCommentCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/15/22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct GroupPostCommentCell: View {
    @State var comment: GroupPostCommentModel
    @ObservedObject var commentsVM = GroupPostCommentViewModel()
    @Binding var focusKeyboard: Bool
    @Binding var placeholder: String
    @Binding var isReplying: Bool
    @Binding var selectedComment : GroupPostCommentModel
    @EnvironmentObject var userVM: UserViewModel
    @State var repliedComments: [GroupPostCommentModel] = []
    @State var fetchedReplies: Bool = false
    @State var showReplies: Bool = false
    
    func userHasLiked() -> Bool{
        return comment.likedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDisliked() -> Bool{
        return comment.dislikedListID?.contains(userVM.user?.id ?? "") ?? false
        
    }
    
    func getTimeSinceComment(date: Date) -> String{
        let interval = (Date() - date)
        
        
        let seconds = interval.second ?? 0
        let minutes = (seconds / 60)
        let hours = (minutes / 60)
        let days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
            if days > 6 {
                let formatter = DateFormatter()
                formatter.dateFormat = "M-d-yy"
                return formatter.string(from: date)
            }
        }
        if time == "0s"{
            return "now"
        }
        else{
            return time
        }
        
    }
    
    var body: some View {
            VStack(alignment: .leading){
                HStack(alignment: .top, spacing: 10){
                    WebImage(url: URL(string: comment.creator?.profilePicture ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width:40,height:40)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 3){
                        HStack{
                            Text("\(comment.creator?.username ?? "")").font(.subheadline).bold()
                            Text("\(self.getTimeSinceComment(date: comment.timeStamp?.dateValue() ?? Date()))").foregroundColor(Color.gray)
                            Spacer()
                        }
                        Text("\(comment.text ?? "")").font(.subheadline)
                        Button(action:{
                            self.placeholder = "reply to \(comment.creator?.username ?? "")"
                            self.isReplying.toggle()
                            self.focusKeyboard.toggle()
                            self.selectedComment = self.comment

                        },label:{
                            Text("Reply").foregroundColor(Color.gray).font(.subheadline)
                        })
                        
                        
                        if (comment.repliedCommentsCount ?? 0 ) > 0 && !self.fetchedReplies {
                            Button(action:{
                                //todo
                                let dp = DispatchGroup()
                                dp.enter()
                                commentsVM.fetchComments(postID: comment.postID ?? " ", parentCommentID: comment.id ?? " ")
                                dp.leave()
                                dp.notify(queue: .main, execute:{
                                    withAnimation{
                                    showReplies = true
                                    self.fetchedReplies = true
                                    }
                                })
                            
                            },label:{
                                HStack(spacing: 1){
                                    Text("Show \(comment.repliedCommentsCount ?? 0) Replies")
                                    Image(systemName: "chevron.down")
                                }.foregroundColor(Color("AccentColor")).font(.subheadline)
                            })
                        }
                       
                    }
                    Spacer()
                    
                        HStack{
                            Button(action:{
                                commentsVM.updateGroupPostUserCommentLike(postID: comment.postID ?? " ", userID: userVM.user?.id ?? " ", commentID: comment.id ?? " ", actionToLike: true) { list in
                                   
                                    self.comment.likedListID = list[0]
                                    self.comment.dislikedListID = list[1]
                                }
                            },label:{
                                VStack(spacing: 1){
                                    Image(systemName: self.userHasLiked() ? "heart.fill" :  "heart").foregroundColor(self.userHasLiked() ? Color("AccentColor") : FOREGROUNDCOLOR).font(.system(size: 18))
                                    Text("\( self.comment.likedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                                }
                            })
                            
                            Button(action:{
                                commentsVM.updateGroupPostUserCommentLike(postID: comment.postID ?? " ", userID: userVM.user?.id ?? " ", commentID: comment.id ?? " ", actionToLike: false) { list in
                                    self.comment.likedListID = list[0]
                                    self.comment.dislikedListID = list[1]
                                }
                            },label:{
                                VStack(spacing: 1){
                                    Image(systemName: self.userHasDisliked() ? "heart.slash.fill" :  "heart.slash").foregroundColor(self.userHasDisliked() ? Color("AccentColor") :  FOREGROUNDCOLOR).font(.system(size: 18))
                                    Text("\(self.comment.dislikedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                                }
                            })
                        }
                    
                    
                }
                    if self.fetchedReplies && showReplies{
                            VStack(alignment: .leading){
                                   
                                ForEach(commentsVM.comments){ fetchedReplyComment in
                                        GroupPostReplyCommentCell(comment: fetchedReplyComment, parentComment: comment, commentsVM: commentsVM, focusKeyboard: $focusKeyboard, placeholder: $placeholder, isReplying: $isReplying, selectedComment: $selectedComment)
                                    }
                                
                               
                            }.padding([.leading,.top])
                        
                        
                        
                            
                            
                        
                      
                        
                    }
                
              
                
                HStack{
                
                    
                    Spacer()
                    
                    if showReplies && fetchedReplies {
                        Button(action:{
                            withAnimation{
                            showReplies.toggle()
                                repliedComments = []
                                self.fetchedReplies = false
                            }
                        },label:{
                            HStack(spacing: 1){
                                Text("Hide Replies")
                                Image(systemName: "chevron.up")
                            }
                        }).foregroundColor(Color("AccentColor")).font(.subheadline)
                    }
                }
                
              
            }.padding(.horizontal,10)
        
      .onAppear{
            commentsVM.fetchComment(postID: comment.postID ?? " ", commentID: comment.id ?? " ") { fetchedComment in
                self.comment = fetchedComment
            }
        }
        
      
    }
}


struct GroupPostReplyCommentCell : View {
    @State var comment: GroupPostCommentModel
    @State var parentComment: GroupPostCommentModel
    @StateObject var commentsVM: GroupPostCommentViewModel
    @Binding var focusKeyboard: Bool
    @Binding var placeholder: String
    @Binding var isReplying: Bool
    @Binding var selectedComment : GroupPostCommentModel
    @EnvironmentObject var userVM: UserViewModel
    @State var repliedComments: [GroupPostCommentModel] = []
    @State var showReplies: Bool = false
    @State var fetchedReplies: Bool = false
    
    
   
    
    func userHasLiked() -> Bool{
        return comment.likedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDisliked() -> Bool{
        return comment.dislikedListID?.contains(userVM.user?.id ?? "") ?? false
        
    }
    
    func getTimeSinceComment(date: Date) -> String{
        let interval = (Date() - date)
        
        
        let seconds = interval.second ?? 0
        let minutes = (seconds / 60)
        let hours = (minutes / 60)
        let days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
            if days > 6 {
                let formatter = DateFormatter()
                formatter.dateFormat = "M-d-yy"
                return formatter.string(from: date)
            }
        }
        if time == "0s"{
            return "now"
        }
        else{
            return time
        }
        
    }
    var body: some View {
      
            
            
            HStack{
                
                VStack(alignment: .leading){
                    HStack(alignment: .top, spacing: 10){
                        WebImage(url: URL(string: comment.creator?.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:30,height:30)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 3){
                            HStack{
                                Text("\(comment.creator?.username ?? "")").font(.subheadline).bold()
                                Text("\(self.getTimeSinceComment(date: comment.timeStamp?.dateValue() ?? Date()))").foregroundColor(Color.gray)
                                Spacer()
                            }
                            Text("\(comment.text ?? "")").font(.subheadline)
                            Button(action:{
                                self.placeholder = "reply to \(comment.creator?.username ?? "")"
                                self.isReplying.toggle()
                                self.focusKeyboard.toggle()
                                self.selectedComment = self.comment
                                
                            },label:{
                                Text("Reply").foregroundColor(Color.gray).font(.subheadline)
                            })
                            
                          
                            
                            HStack{
                                if (comment.repliedCommentsCount ?? 0 ) > 0 {
                                    Button(action:{
                                        //todo
                                        let dp = DispatchGroup()
                                        dp.enter()
                                        commentsVM.fetchComments(postID: comment.postID ?? " ", parentCommentID: comment.id ?? " ")
                                        dp.leave()
                                        dp.notify(queue: .main, execute:{
                                            showReplies = true
                                            self.fetchedReplies = true
                                        })
                                      
                                    },label:{
                                        HStack(spacing: 1){
                                            Text("\(comment.repliedCommentsCount ?? 0) replies")
                                            Image(systemName: "chevron.down")
                                        }.foregroundColor(Color("AccentColor")).font(.subheadline)
                                    })
                                }
                                
                                Spacer()
                                
                                if showReplies {
                                    Button(action:{
                                        withAnimation{
                                        showReplies.toggle()
                                        }
                                    },label:{
                                        Text("Hide Replies")
                                    })
                                }
                            }
                            
                         
                            
                            
                            
                        }
                        Spacer()
                        
                        HStack{
                            Button(action:{
                                commentsVM.updateGroupPostUserCommentLike(postID: parentComment.postID ?? " ", userID: userVM.user?.id ?? " ", commentID: comment.id ?? " ", actionToLike: true) { list in
                                    
                                    self.comment.likedListID = list[0]
                                    self.comment.dislikedListID = list[1]
                                }
                            },label:{
                                VStack(spacing: 1){
                                    Image(systemName: self.userHasLiked() ? "heart.fill" :  "heart").foregroundColor(self.userHasLiked() ? Color("AccentColor") : FOREGROUNDCOLOR).font(.system(size: 18))
                                    Text("\( self.comment.likedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                                }
                            })
                            
                            Button(action:{
                                commentsVM.updateGroupPostUserCommentLike(postID: parentComment.postID ?? " ", userID: userVM.user?.id ?? " ", commentID: comment.id ?? " ", actionToLike: false) { list in
                                    self.comment.likedListID = list[0]
                                    self.comment.dislikedListID = list[1]
                                }
                            },label:{
                                VStack(spacing: 1){
                                    Image(systemName: self.userHasDisliked() ? "heart.slash.fill" :  "heart.slash").foregroundColor(self.userHasDisliked() ? Color("AccentColor") :  FOREGROUNDCOLOR).font(.system(size: 18))
                                    Text("\(self.comment.dislikedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                                }
                            })
                        }
                        if self.fetchedReplies && showReplies{
                                VStack(alignment: .leading){
                                       
                                    ForEach(commentsVM.comments){ fetchedReplyComment in
                                            GroupPostReplyCommentCell(comment: fetchedReplyComment, parentComment: comment, commentsVM: commentsVM, focusKeyboard: $focusKeyboard, placeholder: $placeholder, isReplying: $isReplying, selectedComment: $selectedComment)
                                        }
                                    
                                   
                                }.padding([.leading,.top])
                            
                            
                            
                                
                                
                            
                          
                            
                        }
                        
                    }
                    
                }
            }.padding(.horizontal)
        
        
    }
}
