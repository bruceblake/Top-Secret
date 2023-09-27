//
//  SelectedUserMapView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/5/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct SelectedUserMapView: View {
    @Binding var followUser: Bool
    @Binding var userAnnotations: [UserAnnotations]
    @Binding var selectedUser: User
    var body: some View {
        ZStack{
           
            Map(coordinateRegion: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: selectedUser.latitude ?? 0.0, longitude: selectedUser.longitude ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)).getBinding()!, interactionModes: .all , annotationItems: userAnnotations) { user in
                MapAnnotation(coordinate: user.coordinate) {
                        WebImage(url: URL(string: selectedUser.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())

                }

            }
            
            VStack(alignment: .leading){
                HStack(alignment: .top){
                    Button {
                        self.followUser.toggle()
                    } label: {
                        ZStack{
                            Circle().frame(width:40 ,height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }
                    
                    Spacer()
                    VStack(spacing: 1){
                        WebImage(url: URL(string: selectedUser.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                        Text("\(selectedUser.nickName ?? " ")").bold().font(.body).foregroundColor(FOREGROUNDCOLOR)
                        Text("Last updated now").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.bottom,5)
                    
                    Spacer()
                    
                    Circle().frame(width:40 ,height: 40).foregroundColor(Color.clear)


                }.padding(.top,50).padding(.horizontal,40).background(Rectangle().fill(Color("Background")))
                
                Spacer()
                
                HStack(alignment: .bottom){
                    VStack(alignment: .leading){
                        Text("Distance").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                        Text("\(selectedUser.lastLocationName)").foregroundColor(FOREGROUNDCOLOR).font(.footnote)
                        Text("2 hr, 24 min drive to Bruce").font(.footnote)
                    }.padding(.leading,15)
                    
                    Spacer()
                    Button(action:{
                        
                    },label:{
                        Text("Get Directions").foregroundColor(FOREGROUNDCOLOR).padding(5).padding(.horizontal,25).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                    }).padding(.trailing,15)
                }.frame(width: UIScreen.main.bounds.width).padding(.bottom,10).padding(25).background(Rectangle().fill(Color("Background")))
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


