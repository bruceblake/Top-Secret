//
//  LoadingView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/9/22.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isShowing: Bool
    var body: some View {
        if isShowing {
            ZStack{
                RoundedRectangle(cornerRadius: 15).fill(Color("Color"))
                ProgressView{
                    Text("Loading...")
                        .font(.title2)
                }
            }.frame(width: 120, height: 120, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 25).stroke(Color("Color"),lineWidth: 2))
        }
    }
}

//struct LoadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingView()
//    }
//}
