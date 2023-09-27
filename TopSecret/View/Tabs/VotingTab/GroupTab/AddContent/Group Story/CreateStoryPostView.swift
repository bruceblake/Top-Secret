//
//  CreateStoryPostView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/26/22.
//

import SwiftUI

import AVKit

struct CreateStoryPostView: View {
    
    @StateObject var imagePickerVM = ImagePickerViewModel()
    @StateObject var groupVM = GroupViewModel()
    @ObservedObject var cameraVM = CameraViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM: UserViewModel
    
    @State var avatarImage : UIImage? = nil
    @State var selectedGroup : GroupModel = GroupModel()
    @State var isShowingPhotoPicker: Bool = false
    @State var posts : [UIImage] = []
    @State var showEditStory = false
    @State var player: AVPlayer = AVPlayer()
    var body: some View {
        
        let longPressDrag = LongPressGesture(minimumDuration: 0.1)
            .onEnded { _ in
                print("long press start")
                cameraVM.startRecording()
            }
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onEnded { _ in
                cameraVM.stopRecording()
            }
        
        ZStack{
            
            //camera preview where picture has not been taken
            GeometryReader{ proxy in
                let size = proxy.size
                CameraPreview(camera: cameraVM, size: size)
                
                if !cameraVM.photoHasBeenTaken{
                    ZStack(alignment: .leading){
                        Rectangle()
                            .fill(.black.opacity(0.25))
                        
                        Rectangle()
                            .fill(Color("AccentColor"))
                            .frame(width: size.width * (cameraVM.recordedDuration / cameraVM.maxDuration))
                    }.edgesIgnoringSafeArea(.all).frame(height: 8).frame(maxHeight: .infinity, alignment: .top).offset(y: 10)
                }
                
                
            }
            
            if cameraVM.photoHasBeenTaken {
                MediaPreview(cameraVM: cameraVM)
            }
            
            else{
                VStack{
                    HStack{
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                            
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                                
                                Image(systemName: "chevron.left")
                                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                            }
                        }).padding(.leading,10)
                        
                        Spacer()
                        Text("Create Story Post").font(.title2).fontWeight(.bold)
                        
                        
                        Spacer()
                        
                    }.padding(.top,50)
                    
                    
                    Spacer()
                    
                    HStack{
                        Button(action:{
                            self.isShowingPhotoPicker.toggle()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "photo.on.rectangle")
                            }
                        })  .fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
//                            if let avatarImage = avatarImage{
//                                ImagePicker(avatarImage: $avatarImage, allowsEditing: false)
//                            }
                        })
                        
                        
                        ZStack{
                            Circle().fill(cameraVM.isRecording ? Color("AccentColor") : Color.white).frame(width: 65, height: 65)
                            
                            Circle().stroke(Color("AccentColor"), lineWidth: 4)
                                .frame(width: cameraVM.isRecording ? 85 : 75, height: cameraVM.isRecording ? 85 : 75)
                            
                            
                        }.onTapGesture {
                            cameraVM.takePicture()
                        }.gesture(longPressDrag)
                        
                        
                    }.padding(30).padding(.bottom,10).offset(x: -20)
                    
                    
                }
                
            }
            
            
            
            ZStack {
                if let url = cameraVM.previewURL, cameraVM.showVideoPreview{
                    NavigationLink(destination:Video(player: player, isPlaying: .constant(true)).transition(.move(edge: .trailing))
                                   , isActive: $cameraVM.showVideoPreview, label: {EmptyView()})
                }
            }.animation(.easeInOut, value: cameraVM.showVideoPreview)
            
//            NavigationLink(destination: EditStoryPost(image: $avatarImage), isActive: $showEditStory, label: {EmptyView()})
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//            cameraVM.checkPermission()
        }.onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()){ _ in
            if cameraVM.recordedDuration <= cameraVM.maxDuration && cameraVM.isRecording {
                //increase record duration
                cameraVM.recordedDuration += 0.01
            }
            
            if cameraVM.recordedDuration >= cameraVM.maxDuration && cameraVM.isRecording {
                //if at end of video; stop recording
                cameraVM.stopRecording()
                cameraVM.isRecording = false
            }
        }.onReceive(cameraVM.$previewURL) { url in
            if let url = url {
                self.player = AVPlayer(url: url)
                cameraVM.showVideoPreview.toggle()
            }
        }
        .onChange(of: self.avatarImage) { _ in
            self.showEditStory.toggle()
        }
    }
}





struct CreateStoryPostView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStoryPostView()
    }
}


struct MediaPreview : View {
    @ObservedObject var cameraVM : CameraViewModel

    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    cameraVM.photoHasBeenTaken.toggle()
                },label:{
                Image(systemName: "xmark")
                }).padding(10)
                Spacer()
            }.padding(.top,50)
            Spacer()
            HStack{
                Button(action:{
                    cameraVM.savePicture()
                },label:{
                    Text(cameraVM.hasSavedPhoto ? "Saved" : "Save")
                        .foregroundColor(FOREGROUNDCOLOR)
                        .fontWeight(.semibold)
                        .padding(.vertical,10)
                        .padding(.horizontal)
                        .background(Color("AccentColor"))
                        .clipShape(Capsule())
                    
                })
                
                Button(action:{
                    cameraVM.retakePicture()
                },label:{
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .foregroundColor(FOREGROUNDCOLOR)
                        .padding()
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                    
                })
                Spacer()
            }.padding()
        }
    }
}
