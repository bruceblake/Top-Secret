//
//  AssetModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/25/22.
//

import Foundation
import Photos
import UIKit

struct AssetModel : Identifiable {
    var id = UUID().uuidString
    var asset: PHAsset
    var image: UIImage
    
}
