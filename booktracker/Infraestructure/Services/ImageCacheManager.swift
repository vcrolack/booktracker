//
//  ImageCacheManager.swift
//  booktracker
//
//  Created by Victor rolack on 24-02-26.
//

import Foundation
import UIKit

actor ImageCacheManager {
    static let shared = ImageCacheManager()
    static let memoryCache = NSCache<NSString, UIImage>()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("BookCovers")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        Self.memoryCache.countLimit = 15
    }
    
    nonisolated func getCachedImage(from urlString: String) -> UIImage? {
        Self.memoryCache.object(forKey: urlString as NSString)
    }
    
    func getImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        if let cached = Self.memoryCache.object(forKey: urlString as NSString) {
            return cached
        }
        
        let safeFileName = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        let fileUrl = cacheDirectory.appendingPathComponent(safeFileName)
        
        if fileManager.fileExists(atPath: fileUrl.path),
           let data = try? Data(contentsOf: fileUrl),
           let localImage = UIImage(data: data) {
            Self.memoryCache.setObject(localImage, forKey: urlString as NSString)
            return localImage
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let downloadedImage = UIImage(data: data) else { return nil }
            
            try? data.write(to: fileUrl)
            Self.memoryCache.setObject(downloadedImage, forKey: urlString as NSString)

            return downloadedImage
        } catch {
            print("❌ ImageCacheManager: Error fatal de red -> \(error.localizedDescription)")
            return nil
        }
    }
}
