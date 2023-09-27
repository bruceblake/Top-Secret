//
//  GalleryPostShareView.swift
//  Top Secret
//
//  Created by Bruce Blake on 3/14/22.
//

import SwiftUI

struct GalleryPostShareView: View {
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack{
                
            }
            
            HStack{
                Button(action:{
                    
                },label:{
                    ZStack{
                        Circle()
                    }
                })
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct GalleryPostShareView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryPostShareView()
    }
}
