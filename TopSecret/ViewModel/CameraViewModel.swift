//
//  CameraViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/12/22.
//

import Foundation
import AVFoundation
import SwiftUI
import Photos


struct Photo: Identifiable, Equatable{
    public var id: String
    public var originalData: Data
    
    public init(id: String = UUID().uuidString, originalData: Data) {
            self.id = id
            self.originalData = originalData
        }
}

class CameraViewModel : NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    @Published var photoHasBeenTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var videoOutput = AVCaptureMovieFileOutput()
    
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    @Published var hasSavedPhoto = false
    @Published var pictureData = Data(count: 0)
    
    @Published var cameraPosition : AVCaptureDevice.Position = .back
    
    @Published var isRecording : Bool = false
    @Published var previewURL: URL?
    @Published var showVideoPreview = false
    @Published var recordedDuration: CGFloat = 0
    @Published var maxDuration : CGFloat = 20
    
    
    func checkPermission(){
        
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            self.setUp()
            return
            
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setUp()
                }
            }
            
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp(){
        do{
            
            self.session.beginConfiguration()
            
            let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput){
                self.session.addInput(videoInput)
                self.session.addInput(audioInput)

            }
            
            if self.session.canAddOutput(self.videoOutput) && self.session.canAddOutput(self.photoOutput){
                self.session.addOutput(self.photoOutput)
                self.session.addOutput(self.videoOutput)

            }
            self.session.commitConfiguration()
            
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func takePicture(){
        DispatchQueue.global(qos: .background).async{
            self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async{
                withAnimation{self.photoHasBeenTaken.toggle()}
            }
            
        }
        
        
    }
    
    func retakePicture(){
        DispatchQueue.global(qos: .background).async{
            self.session.startRunning()
            
            DispatchQueue.main.async{
                withAnimation{self.photoHasBeenTaken.toggle()}
                self.hasSavedPhoto = false
            }
        }
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        
        print("picture taken!")
        
        guard let imageData = photo.fileDataRepresentation() else {return}
        self.pictureData = imageData
    }
    
    func savePicture(){
        let image = UIImage(data: self.pictureData)!
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.hasSavedPhoto = true
        
        print("Saved Photo!")
        
    }
    
    func requestAuthorization(completion: @escaping ()->Void) {
            if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else if PHPhotoLibrary.authorizationStatus() == .authorized{
                completion()
            }
        }



    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
            requestAuthorization {
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .video, fileURL: outputURL, options: nil)
                }) { (result, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("Saved successfully")
                        }
                        completion?(error)
                    }
                }
            }
        }


    func startRecording(){
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        videoOutput.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording(){
        videoOutput.stopRecording()
        isRecording = false
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        
        
        
        print(outputFileURL)
        self.previewURL = outputFileURL
    }
    
}
