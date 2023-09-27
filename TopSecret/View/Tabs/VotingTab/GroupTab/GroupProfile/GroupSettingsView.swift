//
//  GroupSettingsView.swift
//  TopSecret
//
//  Created by Bruce Blake on 12/16/21.
//

import SwiftUI

struct GroupSettingsView: View {
    @Environment(\.presentationMode) var dismiss
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @Environment(\.modalMode) var modalMode
    @State var openChangeMOTD : Bool = false
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack(alignment: .center){
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    }).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(.leading)
                    
                    Spacer()
                    
                    Text("Group Settings").fontWeight(.bold).font(.title)
                    
                    Spacer()
                }.padding(.top,50)
                
                ScrollView(){
                  
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Account Actions").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack{
                              
                                SettingsButtonCell(text: "Leave Group", includeDivider: false,  action:{
                                    
                                    selectedGroupVM.leaveGroup()
                                    self.modalMode.wrappedValue = false
                                   
                                    
                                    
                                })
                                
                            }.padding(.vertical,10).background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
            
            
            //navigation links
            NavigationLink(destination: GroupChangeMOTDView(), isActive: $openChangeMOTD) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct GroupSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupSettingsView().colorScheme(.dark)
//    }
//}
