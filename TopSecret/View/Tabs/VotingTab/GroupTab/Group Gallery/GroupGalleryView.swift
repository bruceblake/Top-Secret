//
//  GroupGalleryView.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/30/22.
//

import SwiftUI
import AVKit
//import MediaPicker
import SDWebImageSwiftUI
import AVFoundation



struct GroupGalleryView: View {
    
    @StateObject var groupGalleryVM = GroupGalleryViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var openImageToEdit : Bool = false
    @State var openVideoToEdit : Bool = false
    @State var selectedMediaToEdit : GroupGalleryModel = GroupGalleryModel()
    @StateObject var searchRepository = SearchRepository()
    @State var readyToPost : Bool = false
    @State var selectedOptionIndex : Int = 0
    @State var isShowingMediaPicker : Bool = false
    @State var mediaToShow : [GroupGalleryModel] = []
    @State var urls : [URL] = []
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    func getHStackCount(numberOfImages: Int) -> Int{
        return Int(ceil(Double(numberOfImages/3)))
    }
    
    func shouldDisplayMonth(previousDate: Date, currentDate: Date) -> Bool{
        let previousMonth = Calendar.current.component(.month, from: previousDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        
        return previousMonth != currentMonth
    }
    
    var body: some View {
        
        
        ZStack{
            Color("Background")
            VStack{
                
                
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left").font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading).padding(.trailing,0)
                    
                    Spacer()
                    
                    
                    Text("\(selectedGroupVM.group.groupName)'s Gallery")
                    
                    
                    Spacer()
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                    
                }.padding(.top,50)
                
                VStack{
                    
                            HStack{
                                Spacer()
                                Button(action:{
                                    selectedOptionIndex = 0
                                },label:{
                                    Text("All").foregroundColor(selectedOptionIndex == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                                })
                                Spacer()
                                Button(action:{
                                    selectedOptionIndex = 1
                                },label:{
                                    Text("Favorites").foregroundColor(selectedOptionIndex == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                                })
                                Spacer()
                                Button(action:{
                                    selectedOptionIndex = 2
                                },label:{
                                    Text("Videos").foregroundColor(selectedOptionIndex == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                                })
                                Spacer()
                                Button(action:{
                                    selectedOptionIndex = 3
                                },label:{
                                    Text("Photos").foregroundColor(selectedOptionIndex == 3 ? Color("AccentColor") : FOREGROUNDCOLOR)
                                })
                                Spacer()
                            }
                        
                    
                  
                    Divider()
                    
                    if groupGalleryVM.isLoading {
                        VStack{
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }else{
                        ScrollView(showsIndicators: false){
                                
                                LazyVGrid(columns: columns,spacing: 1) {
                                    
                                    
                                    ForEach(mediaToShow, id: \.id){ image in
                                        if image.isImage ?? false{
                                              
                                                Button(action:{
                                                    self.openImageToEdit.toggle()
                                                    self.selectedMediaToEdit = image
                                                },label:{
                                                    GalleryThumbnailImage(image: image)
                                                    
                                                }).fullScreenCover(isPresented: $openImageToEdit) {
                                                    
                                                } content: {
                                                    EditGalleryImageView(galleryImage: $selectedMediaToEdit, groupGalleryVM: groupGalleryVM)
                                                }
                                            
                                         
                                        }else{
                                            Button(action:{
                                                self.openVideoToEdit.toggle()
                                                self.selectedMediaToEdit = image
                                            },label:{
                                                VideoThumbnailImage(videoUrl: URL(string: image.url ?? " ") ?? URL(fileURLWithPath: " "))
                                            }).fullScreenCover(isPresented: $openVideoToEdit) {
                                                
                                            } content: {
                                                EditGalleryVideoView(galleryMedia: $selectedMediaToEdit, groupGalleryVM: groupGalleryVM)
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                }
                            
                                
                            
                           
                        }
                    }
                }
                
            }
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action:{
                        self.isShowingMediaPicker.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("AccentColor")).frame(width: 55, height: 55)
                            Image(systemName: "plus").font(.system(size: 25)).foregroundColor(FOREGROUNDCOLOR)
                        }.padding([.trailing, .bottom], 30)
                    })
//                    .mediaImporter(isPresented: $isShowingMediaPicker, allowedMediaTypes: .all, allowsMultipleSelection: true) { result in
//                        switch result {
//                            case .success(let urls):
//                                self.urls = urls
//                            case .failure(let error):
//                                print(error)
//                                self.urls = []
//                        }
//                    }
                }
            }
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{                groupGalleryVM.fetchPhotos(userID: USER_ID, groupID: selectedGroupVM.group.id) { fetched in
            self.mediaToShow = groupGalleryVM.fetchedAllMedia
            
        }
        }.onChange(of: urls) { newValue in
            if !newValue.isEmpty {
                // Create a dispatch group to wait for all downloads to finish
                let group = DispatchGroup()
                
                var images: [UIImage] = []
                var videos: [URL] = []
                for url in urls {
                    
                    switch try! url.resourceValues(forKeys: [.contentTypeKey]).contentType! {
                        case let contentType where contentType.conforms(to: .image):
                            //if image
                            group.enter()
                            
                            // Create a URLSession data task for each URL
                            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let error = error {
                                    print("Error downloading photo: \(error.localizedDescription)")
                                } else {
                                    if let data = data, let image = UIImage(data: data) {
                                        // Add the downloaded image to the array
                                        images.append(image)
                                    }
                                }
                                
                                group.leave()
                                
                            }
                            task.resume()
                        case let contentType where contentType.conforms(to: .audiovisualContent):
                            group.enter()
                            videos.append(url)
                            group.leave()
                        default:
                            group.enter()
                            print("error")
                            group.leave()
                    }
                    
                    
                    
                    
                }
                
                // Wait for all downloads to finish before continuing
                group.notify(queue: DispatchQueue.main) {
                    print("All photos downloaded successfully")
                    for image in images {
                        groupGalleryVM.uploadPhoto(image: image, userID: USER_ID, group: selectedGroupVM.group, isPrivate: true) { uploaded in
                            if uploaded{
                                groupGalleryVM.fetchPhotos(userID: USER_ID, groupID: selectedGroupVM.group.id) { fetched in
                                    switch selectedOptionIndex {
                                        case 0:
                                            mediaToShow = groupGalleryVM.fetchedAllMedia
                                        case 1:
                                            mediaToShow = groupGalleryVM.fetchedFavoriteMedia
                                        default:
                                            mediaToShow = groupGalleryVM.fetchedAllMedia
                                    }
                                }
                            }
                        }
                    }
                    for video in videos {
                        groupGalleryVM.uploadVideo(url: video, group: selectedGroupVM.group) { uploaded in
                            if uploaded{
                                groupGalleryVM.fetchPhotos(userID: USER_ID, groupID: selectedGroupVM.group.id) { fetched in
                                    switch selectedOptionIndex {
                                        case 0:
                                            mediaToShow = groupGalleryVM.fetchedAllMedia
                                        case 1:
                                            mediaToShow = groupGalleryVM.fetchedFavoriteMedia
                                        default:
                                            mediaToShow = groupGalleryVM.fetchedAllMedia
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
                
                
                
                
            }
        }.onChange(of: selectedOptionIndex) { newValue in
            switch newValue {
                case 0:
                    mediaToShow = groupGalleryVM.fetchedAllMedia
                case 1:
                    mediaToShow = groupGalleryVM.fetchedFavoriteMedia
                default:
                    mediaToShow = groupGalleryVM.fetchedAllMedia
            }
        }
        
        
        
        
    }
    
}






struct GalleryThumbnailImage : View {
    @State var image: GroupGalleryModel
    var body: some View{
        ZStack{
            AsyncImage(url: URL(string: image.url ?? " ") ?? URL(string: "turd")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width/3, height: 200)
                    .clipped()
            } placeholder: {
                ZStack{
                    Rectangle().foregroundColor(Color("Color")).frame(width: UIScreen.main.bounds.width/3, height: 200)
                    ProgressView()
                }
            }
            
        }.edgesIgnoringSafeArea(.all)
    }
}


struct VideoThumbnailImage: View {
    var videoUrl: URL = URL(fileURLWithPath: " ")
    var thumbnailUrl : URL = URL(fileURLWithPath: " ")
    var width : CGFloat = UIScreen.main.bounds.width/3
    var height : CGFloat = 200
    
    func getVideoDuration(url: URL) -> Double {
        return AVURLAsset(url: url).duration.seconds
    }
    var body: some View {
        
        ZStack{
            WebImage(url: thumbnailUrl)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
            VStack{
                Spacer()
                HStack{
                    Text("\(getVideoDuration(url: videoUrl).formattedTimeString)").shadow(radius: 2).foregroundColor(FOREGROUNDCOLOR).padding([.bottom,.leading],5)
                    Spacer()
                }
            }
        }.frame(width: width, height: height)
        .edgesIgnoringSafeArea(.all)
    }
}

extension Double {
    var formattedTimeString: String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
}




struct EditGalleryVideoView : View {
    
    @Binding var galleryMedia : GroupGalleryModel
    
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @StateObject var groupGalleryVM : GroupGalleryViewModel
    @StateObject var editVM = EditGalleryMediaViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State var changedMedia: Bool = false
    @State var isPlaying: Bool = false
    let imageSaver = ImageSaver()
    var player : AVPlayer {
        AVPlayer(url: URL(string: galleryMedia.url ?? " ") ?? URL(fileURLWithPath: " "))
    }
    
    
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Video(player: player, isPlaying: $isPlaying).cornerRadius(12)
                
                
                VStack{
                    HStack{
                        Button(action:{
                            self.player.pause()
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        })
                        
                     
                        
                        Button(action:{
                            let dp = DispatchGroup()
                            dp.enter()
                            if editVM.userHasFavorited(userID: USER_ID){
                                editVM.unfavoriteMedia(mediaID: galleryMedia.id ?? " ", groupID: selectedGroupVM.group.id)
                            }else{
                                editVM.favoriteMedia(mediaID: galleryMedia.id ?? " ", groupID: selectedGroupVM.group.id)
                            }
                            dp.leave()
                            dp.notify(queue: .main, execute: {
                                editVM.fetchGalleryMedia(groupID: selectedGroupVM.group.id, mediaID: galleryMedia.id ?? " ")
                                self.changedMedia = true
                            })
                            
                            
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: editVM.userHasFavorited(userID: USER_ID) ? "star.fill" : "star").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        })
                        
                        
                        Spacer()
                        if galleryMedia.creatorID ?? "" == USER_ID {
                            Button(action:{
                                presentationMode.wrappedValue.dismiss()
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    Image(systemName: "trash").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                                }
                            })
                        }
                        
                        
                    }.padding(.top,50).padding(.horizontal)
                    Spacer()
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            editVM.fetchGalleryMedia(groupID: selectedGroupVM.group.id, mediaID: galleryMedia.id ?? " ")
        }.onDisappear{
            if changedMedia{
                groupGalleryVM.fetchPhotos(userID: USER_ID, groupID: selectedGroupVM.group.id) { fetched in
                }
            }
           
        }
        
        
    }
}


struct EditGalleryImageView : View {
    
    @Binding var galleryImage : GroupGalleryModel
    @Environment(\.presentationMode) var presentationMode
    let imageSaver = ImageSaver()
    @StateObject var groupGalleryVM : GroupGalleryViewModel
    @StateObject var editVM = EditGalleryMediaViewModel()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @State var changedMedia: Bool = false
    var body: some View {
        GeometryReader { geo in
            ZStack{
                AsyncImage(url: URL(string: galleryImage.url ?? " ") ?? URL(fileURLWithPath: " ") ) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height).cornerRadius(12)
                } placeholder: {
                    ProgressView()
                }
                
                
                VStack{
                    HStack{
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        }).padding(.leading)
                        
                        Button(action:{
                            imageSaver.writeToPhotoAlbum(image: galleryImage.image ?? UIImage(named: "Icon")!)
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "square.and.arrow.up").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        })
                        
                        Button(action:{
                            let dp = DispatchGroup()
                            dp.enter()
                            if editVM.userHasFavorited(userID: USER_ID){
                                editVM.unfavoriteMedia(mediaID: galleryImage.id ?? " ", groupID: selectedGroupVM.group.id)
                            }else{
                                editVM.favoriteMedia(mediaID: galleryImage.id ?? " ", groupID: selectedGroupVM.group.id)
                            }
                            dp.leave()
                            dp.notify(queue: .main, execute: {
                                    editVM.fetchGalleryMedia(groupID: selectedGroupVM.group.id, mediaID: galleryImage.id ?? " ")
                                self.changedMedia = true
                            })
                            
                            
                        },label:{
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: editVM.userHasFavorited(userID: USER_ID) ? "star.fill" : "star").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                            }
                        })
                        
                        
                        Spacer()
                        
                        if galleryImage.creatorID ?? "" == USER_ID {
                            Button(action:{
                                presentationMode.wrappedValue.dismiss()
                            },label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                    Image(systemName: "trash").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                                }
                            })
                        }
                        
                    }.padding(.top,50)
                    Spacer()
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            editVM.fetchGalleryMedia(groupID: selectedGroupVM.group.id, mediaID: galleryImage.id ?? " ")
        }.onDisappear{
            if changedMedia {
                groupGalleryVM.fetchPhotos(userID: USER_ID, groupID: selectedGroupVM.group.id) { fetched in
                }
            }
         
        }
        
        
    }
}
