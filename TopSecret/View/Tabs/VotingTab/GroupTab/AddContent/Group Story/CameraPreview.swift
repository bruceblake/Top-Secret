//
//  CameraPreview.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/12/22.
//

import SwiftUI
import AVFoundation
import AVKit

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera : CameraViewModel
    var size: CGSize
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame.size = size
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        DispatchQueue.global(qos: .background).async{
        camera.session.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


struct VideoPreview : View {
    @Binding var showPreview : Bool
    @Binding var player : AVPlayer
    var body: some View {
        ZStack{
            
            GeometryReader { proxy in
                let size = proxy.size
                VideoPlayer(player: $player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

