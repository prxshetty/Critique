//
//  PermissionsHelper.swift
//  Critique
//
//  Created by Antigravity on 19.04.26.
//

import Foundation
import ApplicationServices
import CoreGraphics
import AppKit

struct PermissionsHelper {
    static func checkAccessibility() -> Bool {
        return AXIsProcessTrusted()
    }
    
    static func requestAccessibility() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as CFString
        let options: CFDictionary = [key: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            openPrivacyPane(anchor: "Privacy_Accessibility")
        }
    }

    static func checkScreenRecording() -> Bool {
        return CGPreflightScreenCaptureAccess()
    }

    static func requestScreenRecording(completion: @escaping (Bool) -> Void) {
        // CGRequestScreenCaptureAccess may present system UI, so it must run on the main thread.
        let granted = CGRequestScreenCaptureAccess()
        completion(granted)
    }
    
    static func openPrivacyPane(anchor: String? = nil) {
        // We try the legacy protocol first as it's a reliable alias on new systems (including 26.3.1+)
        // and the primary protocol for older ones.
        let protocols = ["x-apple.systempreferences", "x-apple.systemsettings"]
        let path = "com.apple.preference.security"
        
        for proto in protocols {
            var urlString = "\(proto):\(path)"
            if let anchor = anchor {
                urlString += "?\(anchor)"
            }
            
            if let url = URL(string: urlString) {
                // If open returns true, we successfully redirected the user
                if NSWorkspace.shared.open(url) {
                    return
                }
            }
        }
    }
}
