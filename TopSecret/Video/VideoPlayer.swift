import SwiftUI
import AVKit
//import ExyteMediaPicker


struct Video: View {
    @State var player : AVPlayer
    @Binding var isPlaying: Bool
    @State var showControls : Bool = true
    @State var value: Float = 0
    @StateObject var indexVM : IndexViewModel = IndexViewModel()
    var index: Int? = nil
    @State var videoHasEnded: Bool = false

    
    func restartVideo(){
        self.player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        self.videoHasEnded = false
    }
    var body: some View{
            ZStack{
                VideoPlayer(player: $player).disabled(true)
                if !isPlaying && !videoHasEnded {
                    Image(systemName: "play.fill").foregroundColor(Color.gray).font(.largeTitle).frame(width: 150, height: 150)
                }
                if videoHasEnded{
                    //restart
                    Button {
                        self.restartVideo()
                        self.player.play()
                        self.isPlaying = true
                    } label: {
                        Image(systemName: "arrow.clockwise").foregroundColor(Color.gray).font(.largeTitle).frame(width: 150, height: 150)
                    }

                }
               
            }.edgesIgnoringSafeArea(.all).cornerRadius(12)
            .onTapGesture {
                if isPlaying{
                    isPlaying = false
                    self.player.pause()
                }else{
                    isPlaying = true
                    self.player.play()
                }
                
            }.onDisappear{
                isPlaying = false
                self.player.pause()
            }.onAppear{
                self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { _ in
                    if Float(self.player.currentTime().seconds / (self.player.currentItem?.duration.seconds)!) == 1.0 {
                        self.isPlaying = false
                        self.videoHasEnded = true
                    }
                }
            }.onChange(of: isPlaying) { newValue in
                if (indexVM.index == index && index != nil) || index == nil{
                    if newValue{
                        self.player.play()
                    }else{
                        self.player.pause()
                    }
                }
            }

    }
}


struct VideoPlayer : UIViewControllerRepresentable {
    @Binding var player: AVPlayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {

        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {

    }
    



}

