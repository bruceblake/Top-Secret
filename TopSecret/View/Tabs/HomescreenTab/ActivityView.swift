
//  ActivityView.swift
//  Top Secret
//
//  Created by Bruce Blake on 4/16/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import AVFoundation

struct ActivityView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @ObservedObject var notificationVM = GroupNotificationViewModel()
    @State var showEvent : Bool = false
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @State var openChat : Bool = false
    @State var showUsers : Bool = false
    @State var selectedPoll: PollModel = PollModel()
    @State var selectedEvent: EventModel = EventModel()
    @State var filterType = 0
    @Binding var shareType: String

    var body: some View {
        
        ZStack{
            Color("Background")
            ScrollView(showsIndicators: false){
                VStack(spacing: 20){
                    
                    
                    HStack(alignment: .top){
                        
                        Text("Today").foregroundColor(FOREGROUNDCOLOR).font(.title).bold()
                        Spacer()
                        
                        
                     
                            Menu {
                                Button(action:{
                                    filterType = 0
                                },label:{
                                    Text("All")
                                })
                                Button(action:{
                                    withAnimation{
                                        filterType = 1
                                    }
                                },label:{
                                    Text("Events")
                                })
                                Button(action:{
                                    withAnimation{
                                        filterType = 2
                                    }
                                },label:{
                                    Text("Polls")
                                })
                            } label: {
                                HStack(alignment: .top, spacing: 3){
                                    switch filterType{
                                        case 0:
                                            Text("All").foregroundColor(FOREGROUNDCOLOR)
                                        case 1:
                                            Text("Events").foregroundColor(FOREGROUNDCOLOR)
                                        case 2:
                                            Text("Polls").foregroundColor(FOREGROUNDCOLOR)
                                    default:
                                        Text("Unknown")
                                    }
                                   
                                    Image(systemName: "chevron.down").foregroundColor(Color.black).font(.footnote)
                                }.padding(3).padding(.horizontal,5).background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                            }

                         
                        
                        
                    }.padding([.top,.horizontal])
                    
                    GroupFeed(selectedPoll: $selectedPoll,selectedEvent: $selectedEvent,shareType: $shareType, filterOption: $filterType).environmentObject(selectedGroupVM)
                    
                    
                }.padding(.bottom, UIScreen.main.bounds.height / 4)
                
            }
            
            
            BottomSheetView(isOpen: $showUsers, maxHeight: UIScreen.main.bounds.height * 0.45){
                ShowAllUsersVotedView(showUsers: $showUsers, poll: $selectedPoll)
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
         
            notificationVM.readAllNotification(userID: USER_ID, groupID: selectedGroupVM.group.id, notifications: selectedGroupVM.notifications)
        }

    }
}


struct GroupFeed : View {
    @EnvironmentObject var selectedGroupVM: SelectedGroupViewModel
    @Binding var selectedPoll: PollModel
    @Binding var selectedEvent: EventModel
    @Binding var shareType: String
    @Binding var filterOption : Int
    var sortedFeed: [FeedItemObjectModel] {
        
        let feed : [Any] = (selectedGroupVM.polls + selectedGroupVM.events + selectedGroupVM.notifications)
        var arrayToReturn : [FeedItemObjectModel] = []
        for item in feed{
            arrayToReturn.append(self.parseIntoFeedObject(feedItem: item) ?? FeedItemObjectModel())
        }
        
        
        return arrayToReturn.sorted {($0.timeStamp?.dateValue() ?? Date()) > ($1.timeStamp?.dateValue() ?? Date())}
    }
    
    func parseIntoFeedObject(feedItem: Any) -> FeedItemObjectModel? {
        if let event = feedItem as? EventModel  {
            let data = ["id": event.id,
                        "timeStamp": event.timeStamp ?? Timestamp(),
                        "event": event,
                        "itemType":FeedItemObjectModel.ItemType.event] as [String: Any]
            return FeedItemObjectModel(dictionary: data)
        } else if let poll = feedItem as? PollModel  {
            let data = ["id": poll.id ?? "",
                        "timeStamp": poll.timeStamp ?? Timestamp(),
                        "poll": poll,
                        "itemType":FeedItemObjectModel.ItemType.poll] as [String: Any]
            return FeedItemObjectModel(dictionary: data)
        } else if let notification = feedItem as? GroupNotificationModel {
            let data = ["id": notification.id ?? "",
                        "timeStamp": notification.timeStamp ?? Timestamp(),
                        "notification": notification,
                        "itemType":FeedItemObjectModel.ItemType.notification] as [String: Any]
            return FeedItemObjectModel(dictionary: data)
        }else {
            // Return nil if feedItem is not of any of the expected types
            return nil
        }
    }
    
    
    
    
    
    var body : some View {
        ZStack{
            Color("Background")
            VStack(spacing: 10){
                switch filterOption{
                    case 0: //all
                    ForEach(sortedFeed.uniqued(), id: \.id){ item in
                        switch item.itemType {
                        case .event:
                            EventCell(event: item.event ?? EventModel(), selectedEvent: $selectedEvent).frame(width: UIScreen.main.bounds.width-20)
                        case .poll:
                            PollCell(poll: item.poll ?? PollModel(), selectedPoll: $selectedPoll).frame(width: UIScreen.main.bounds.width-20)
                            case .notification:
                            GroupNotificationCell(groupNotification: item.notification ?? GroupNotificationModel()).frame(width: UIScreen.main.bounds.width-20)
                        default:
                            Text("Unknown")
                        }
                        
                    }
                    case 1: //Events
                    ForEach(selectedGroupVM.events.uniqued(), id: \.id){ event in
                        EventCell(event: event, selectedEvent: $selectedEvent).frame(width: UIScreen.main.bounds.width-20)
                    }
                    case 2: //Polls
                    ForEach(selectedGroupVM.polls, id: \.id) { poll in
                        PollCell(poll: poll ?? PollModel(), selectedPoll: $selectedPoll).frame(width: UIScreen.main.bounds.width-20)
                    }
                  
                    default:
                        Text("Unknown")
                }
             
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}



extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
