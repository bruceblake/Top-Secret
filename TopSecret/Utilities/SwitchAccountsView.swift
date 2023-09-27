//
//  SwitchAccountsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/1/22.
//

import SwiftUI

struct SwitchAccountsView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack{
                HStack{
                    Circle().frame(width: 30, height:30)
                    Text("Bruce")
                }
            }
        }
    }
}

struct SwitchAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchAccountsView()
    }
}
