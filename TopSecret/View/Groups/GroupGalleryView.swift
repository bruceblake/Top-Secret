//
//  GroupGalleryView.swift
//  TopSecret
//
//  Created by Bruce Blake on 12/7/21.
//

import SwiftUI

struct GroupGalleryView: View {
    var group: Group
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var groupVM = GroupViewModel()
    @State var text = ""
    var body: some View {
        CustomTextField(text: $text, placeholder: "MOTD", isPassword: false, isSecure: false, hasSymbol: false, symbol: "").padding()
        
        Button(action:{
            groupVM.changeMOTD(motd: text, groupID: group.id, userID: userVM.user?.id ?? "")
        },label:{
            Text("Save")
        })
    }
}
//
//struct GroupGalleryView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupGalleryView()
//    }
//}
