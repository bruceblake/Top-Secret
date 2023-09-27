//
//  CreateGroupView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct CreateGroupView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var groupVM = GroupViewModel()
    @State var groupName: String = ""
    @State var memberLimit: Int = 0
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "Icon")!

    @Binding var goBack: Bool
    
    var body: some View {
        ZStack{
            Color("Background")
        VStack{
            
            
            Text("Create Group!").fontWeight(.bold).font(.title)
            
            CustomTextField(text: $groupName, placeholder: "Group Name", isPassword: false, isSecure: false, hasSymbol: false,symbol: "phone").padding(.horizontal,20)
            
       
            
            Button(action:{
                isShowingPhotoPicker.toggle()
            },label:{
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width:45,height:45)
                    .clipShape(Circle())
                    .padding()
            }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                ImagePicker(avatarImage: $avatarImage, allowsEditing: true)
            })
            
            Button(action:{
                groupVM.createGroup(groupName: groupName, memberLimit: memberLimit, dateCreated: Date(), users: [userVM.user?.id ?? ""],image: avatarImage)
                presentationMode.wrappedValue.dismiss()
            },label:{
                Text("Create Group")
                    
            })
            

        
        }
            
    }
}
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView(goBack: .constant(false))
    }
}
