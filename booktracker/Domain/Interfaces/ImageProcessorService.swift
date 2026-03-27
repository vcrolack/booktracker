//
//  ImageProcessorService.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import Foundation
import UIKit
import CoreGraphics

protocol ImageProcessorService: Sendable {
    func resizeAndCompress(data: Data, targetSize: CGSize) -> Data?
    func saveImage(data: Data, fileName: String, folderName: String) -> String?
    func loadImage(fileName: String, folderName: String) -> UIImage?
    func deleteImage(fileName: String, folderName: String) -> Bool
    func getStorageUsage(folders: [String]) -> Int64
}
extension ImageProcessorService {
    func resizeAndCompress(data: Data) -> Data? {
        resizeAndCompress(data: data, targetSize: CGSize(width: 500, height: 700))
    }
}

