//
//  ProfileImageEntity.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 03/01/2026.
//

import SwiftData
import Foundation

@Model
class ProfileImageEntity {

    @Attribute(.unique) var userId: String
     var imageData: Data

    init(userId: String, imageData: Data) {
        self.userId = userId
        self.imageData = imageData
    }
}


