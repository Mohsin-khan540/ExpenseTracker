//
//  AppInfo.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 02/01/2026.
//

import Foundation

import Foundation

struct AppInfo {
    static var version: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (Build \(build))"
    }
}
