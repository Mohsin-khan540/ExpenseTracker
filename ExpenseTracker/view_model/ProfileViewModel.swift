//
//  ProfileViewModel.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 03/01/2026.
//

import SwiftUI
import SwiftData
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    
    //SwiftData database
    private let context : ModelContext
    
    //image shown on Profile screen
    @Published var profileImage : UIImage?
    
    // we will fetch this values from firestore which already there
    @Published var username: String = ""
    
    private let db = Firestore.firestore()

    
    //image appears automatically when profile opens
    init(context: ModelContext) {
        self.context = context
        loadProfileImage()
        loadProfileInfo()
    }
   
    func loadProfileInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users")
            .document(uid)
            .getDocument { snapshot, error in

                if let error = error {
                    print("Failed to load profile info:", error)
                    return
                }

                guard let data = snapshot?.data() else { return }

                Task { @MainActor in
                    self.username = data["username"] as? String ?? ""
                }
            }
    }
  func  loadProfileImage() {
      //No user = no profile image
      guard let uid = Auth.auth().currentUser?.uid else {
          profileImage = nil
          return
      }
      //Fetch only image where userId == logged-in user
      let descriptor = FetchDescriptor<ProfileImageEntity>(
        predicate: #Predicate {$0.userId == uid}
      )
      
      /*“When profile opens, check database →
      //if image exists → show it
      else → show default avatar” */
      
      if let entity = try? context.fetch(descriptor).first{
          profileImage = UIImage(data: entity.imageData)
      }else{
          profileImage = nil
      }
    }
    
    //Save or update profile image
    
    func saveProfileImage(_ image : UIImage){
       guard let uid = Auth.auth().currentUser?.uid,
             //Image converted to compressed JPEG
             let data = image.jpegData(compressionQuality: 0.8)else{
           return
       }
        let descriptor = FetchDescriptor<ProfileImageEntity>(
            predicate: #Predicate{$0.userId == uid}
        )
        //If image exists → update it , if no image create new one
        if let existing = try?context.fetch(descriptor).first{
            existing.imageData = data
        }else{
            let entity = ProfileImageEntity(userId: uid, imageData: data)
            context.insert(entity)
        }
        //Save to database & update UI
        try? context.save()
        profileImage = image
    }
    
    //Remove profile image
    func deleteProfileImage(){
        //login user
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let descriptor = FetchDescriptor<ProfileImageEntity>(
            predicate: #Predicate{$0.userId == uid}
        )
        //Remove image permanently from local DB
        if let existing = try?context.fetch(descriptor).first{
            context.delete(existing)
            try? context.save()
        }
        profileImage = nil
    }
    
    func updateProfileInfo(
        username: String
    ) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let data: [String: Any] = [
            "username": trimmedUsername
        ]

        db.collection("users")
            .document(uid)
            .updateData(data) { error in
                if let error = error {
                    print("Failed to update profile:", error)
                    return
                }

                Task { @MainActor in
                    self.username = trimmedUsername
                }
            }
    }

}

