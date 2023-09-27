//
//  ContentView.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/2/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel : UserAuthViewModel
    @State var selectedOption: String = "text"
    @State var isShowingNewPostView = true
    @State var selectedTab = 0
    @State var storedTab = 0

    var body: some View {
        //if there is a user signed in then go to the Tab View else go to the register view
            if viewModel.userSession != nil{
                NavigationView {
                    GeometryReader { math in
                        TabView(selection: $selectedTab) {
                            VotingView()
                                .tabItem {
                                    Image(systemName: "checkmark")
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 128, height: 128)
                                }.tag(2)
                                .onAppear { storedTab = 2 }
                            MessageView()
                                .tabItem {
                                    Image(systemName: "message")
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 128, height: 128)
                                }.tag(1)
                                .onAppear { storedTab = 1 }
                            HomeScreenView()
                                .tabItem {
                                    Image(systemName: "house")

                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 128, height: 128)
                                }.tag(0)
                                .onAppear { storedTab = 0 }
                            EventView()
                                .tabItem {
                                    Image(systemName: "text.book.closed")
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 128, height: 128)
                                }.tag(3)
                                .onAppear{storedTab = 3}
                            AddContentView(isPresented: $isShowingNewPostView, selectedTab: $selectedTab, storedTab: $storedTab, selectedOption: $selectedOption)
                                .tabItem {
                                    Image(systemName: "plus")
                                        .scaledToFill()
                                        .foregroundColor(.gray)
                                        .frame(width: 128, height: 128)
                                }.tag(4)
                                .onAppear { isShowingNewPostView = true }
                        }.accentColor(Color("TabColor"))
                        .foregroundColor(.gray)
                        .background(Color.gray)
                        .toolbar {
                            
                            ToolbarItem(placement: .navigationBarLeading, content: {
                                Button(action: { viewModel.signOut() }, label: {
                                        Image("Hamburger_icon")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                })
                            })
                            
                            ToolbarItem(placement: .principal) {
                                Image("FinishedIcon")
                                    .resizable()
                                    .frame(width: 64, height: 64)
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing, content: {
                                Button(action: {}, label: {
                                    Image(systemName: "person.3.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                })
                            })
                        }
                    }
                }.accentColor(Color("iconColor"))
            }else{
               RegisterView()
            }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
