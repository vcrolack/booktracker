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
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("BookCovers")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func getImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        let safeFileName = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        let fileUrl = cacheDirectory.appendingPathComponent(safeFileName)
        
        if fileManager.fileExists(atPath: fileUrl.path),
           let data = try? Data(contentsOf: fileUrl),
           let localImage = UIImage(data: data) {
            return localImage
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloadedImage = UIImage(data: data) else { return nil }
            
            try? data.write(to: fileUrl)
            
            return downloadedImage
        } catch {
            print("Failed to fetch image from \(url)")
            return nil
        }
    }
}
