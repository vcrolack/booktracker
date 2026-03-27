//
//  SettingsViewModel.swift
//  booktracker
//
//  Created by Victor rolack on 20-03-26.
//

import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {
    var storageUsage: String? = nil
    
    var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "user_name") }
    }
    
    var userAvatar: String {
        didSet { UserDefaults.standard.set(userAvatar, forKey: "user_avatar") }
    }
    
    var selectedTheme: AppTheme {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "app_theme")}
    }
    
    var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")}
    }
    
    private var imageProcessor: ImageProcessorService
    
    init(imageProcessor: ImageProcessorService) {
        self.imageProcessor = imageProcessor
        self.userName = UserDefaults.standard.string(forKey: "user_name") ?? "Usuario"
        self.userAvatar = UserDefaults.standard.string(forKey: "user_avatar") ?? "📖"
        
        let savedTheme = UserDefaults.standard.string(forKey: "app_theme") ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: savedTheme) ?? .system
        
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }
    
    func clearImageCache() {
        print("[SETTINGS VM] Clearing image cache...")
    }
    
    func calculateStorage() {
        let processor = self.imageProcessor
        
        Task {
            let folders = ["CollectionCovers", "BookCovers"]
            
            let bytes = await Task.detached(priority: .background) {
                return await processor.getStorageUsage(folders: folders)
            }.value
            
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB, .useKB, .useGB]
            formatter.countStyle = .file
                
            self.storageUsage = formatter.string(fromByteCount: bytes)
        }
    }
}
