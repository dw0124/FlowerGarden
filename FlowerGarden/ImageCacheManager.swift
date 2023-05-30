//
//  ImageCacheManager.swift
//  FlowerGarden
//
//  Created by 김두원 on 2023/05/16.
//

import Foundation
import UIKit

class ImageCacheManager {
   
   static let shared = NSCache<NSString, UIImage>()
   
   private init() {}
}

