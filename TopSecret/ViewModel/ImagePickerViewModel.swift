//
//  ImagePickerViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/25/22.
//

import Foundation
import Photos
import SwiftUI
import AVKit

class ImagePickerViewModel : NSObject, ObservableObject , PHPhotoLibraryChangeObserver{
    @Published var showImagePicker = false
    @Published var libraryStatus = LibraryStatus.denied
    @Published var fetchedPhotos : [AssetModel] = []
    
    @Published var allPhotos : PHFetchResult<PHAsset>!
    
    @Published var showPreview = false
    @Published var selectedImagePreview : UIImage!
    @Published var selectedVideoPreview: AVAsset!
    
    func openImagePicker(){
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if fetchedPhotos.isEmpty{
            fetchPhotos()
        }
        
        withAnimation{showImagePicker.toggle()}
    }
    
    func setUp(){
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self] status in
            
            DispatchQueue.main.async{
                switch status {
                    
                    
                case .denied: libraryStatus = .denied
                case .authorized: libraryStatus = .authorized
                case .limited: libraryStatus = .limited
                default: libraryStatus = .denied
                    
                    
                }
            }
          
            
        }
        
        PHPhotoLibrary.shared().register(self)
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let _ = allPhotos else {return}
    
        if let updates = changeInstance.changeDetails(for: allPhotos){
            
            let updatedPhotos = updates.fetchResultAfterChanges
            
            updatedPhotos.enumerateObjects { [self] asset, index, _ in
                if !allPhotos.contains(asset){
                    getImageFromAsset(asset: asset,size: CGSize(width: 115, height: 115)) { image in
                        DispatchQueue.main.async {
                            fetchedPhotos.append(AssetModel(asset: asset, image: image))
                        }
                    }
                }
            }
            
            allPhotos.enumerateObjects { asset, index, _ in
                if !updatedPhotos.contains(asset){
                    DispatchQueue.main.async{
                        self.fetchedPhotos.removeAll(){ result -> Bool in
                            return result.asset == asset
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.allPhotos = updatedPhotos
            }
            
        }
    }
    
    func fetchPhotos(){
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
        
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false
        
        
        let fetchedResults = PHAsset.fetchAssets(with: options)
        
        allPhotos = fetchedResults
        
        fetchedResults.enumerateObjects { [self] asset, index, _ in
            getImageFromAsset(asset: asset, size: CGSize(width: 115, height: 115)) { image in
                fetchedPhotos.append(AssetModel(asset: asset, image: image))
            }
        }
    }
    
    func getImageFromAsset(asset: PHAsset,size: CGSize, completion: @escaping (UIImage) -> ()){
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = false
        
        let size = CGSize(width: 115, height: 115)
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { image, _ in
            guard let resizedImage = image else {return}
            
            completion(resizedImage)
        }
    }
    
    
    func extractPreviewData(asset: PHAsset){
        
        let manager = PHCachingImageManager()
        if asset.mediaType == .image{
            getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { image in
                self.selectedImagePreview = image
            }
        }
        if asset.mediaType == .video{
            let videoManager = PHVideoRequestOptions()
            videoManager.deliveryMode = .highQualityFormat
            
            manager.requestAVAsset(forVideo: asset, options: videoManager) { videoAsset, _, _ in
                guard let videoUrl = videoAsset else {return}
                
                DispatchQueue.main.async {
                    self.selectedVideoPreview = videoUrl
                }
            }
        }
    }
}


enum LibraryStatus {
    case denied
    case authorized
    case limited
}
