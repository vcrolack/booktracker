//
//  ImageProcessor.swift
//  booktracker
//
//  Created by Victor rolack on 18-03-26.
//

import UIKit
import Foundation

struct ImageProcessor: ImageProcessorService {
    private var baseDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
    
    private func getDirectory(for folder: String) -> URL {
        let url = baseDirectory.appendingPathComponent(folder)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        return url
    }
    
    
    /// Procesa una imagen para que sea apta para almacenamiento en DB
        /// - Parameters:
        ///   - data: Datos originales de la imagen
        ///   - targetSize: Tamaño máximo deseado (por defecto 500px para portadas)
        /// - Returns: Datos comprimidos en JPEG o nil si falla
    ///
    func resizeAndCompress(data: Data, targetSize: CGSize = CGSize(width: 500, height: 700)) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage.jpegData(compressionQuality: 0.7)
    }
    
    func saveImage(data: Data, fileName: String, folderName: String) -> String? {
        guard let compressed = resizeAndCompress(data: data) else { return nil }
        
        let fileUrl = getDirectory(for: folderName).appendingPathComponent(fileName)
        
        do {
            try compressed.write(to: fileUrl, options: .atomic)
            return fileName
        } catch {
            print("[IMAGE PROCESSOR] Error writing image to \(folderName): \(error)")
            return nil
        }
    }
    
    func loadImage(fileName: String, folderName: String) -> UIImage? {
        let fileUrl = getDirectory(for: folderName).appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileUrl) else { return nil }
        return UIImage(data: data)
    }
    
    func deleteImage(fileName: String, folderName: String) -> Bool {
        let fileUrl = getDirectory(for: folderName).appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            print("[Image Processor] File not does exist, no need to delete: \(fileName)")
            return true
        }
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
            print("[Image Processor] Successfully deleted: \(fileName)")
            return true
        } catch {
            print("[Image Processor] Error deleting image: \(error.localizedDescription)")
            return false
        }
    }
}
