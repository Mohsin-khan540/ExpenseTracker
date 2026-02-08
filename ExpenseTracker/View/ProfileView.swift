//
//  ProfileView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 20/12/2025.


import PhotosUI
import SwiftData
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @State private var showImageOptions = false
    @State private var showGalleryPicker = false
    @State private var showCamera = false
    @State private var showEditProfile = false
    
    @State private var uiProfileImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    
    @EnvironmentObject var AuthVM : AuthViewModel
    @Environment(\.modelContext) private var context
    @StateObject private var profileVM: ProfileViewModel
    @State private var showLogoutAlert = false
    
    @State private var showImagePreview = false
    
    @State private var showRemovePhotoAlert = false
    
    init(context: ModelContext) {
            _profileVM = StateObject(
                wrappedValue: ProfileViewModel(context: context)
            )
        }
    
    var body: some View {
        NavigationStack {
            List {
                VStack(spacing: 12) {

                    ZStack(alignment: .bottomTrailing) {
                        
                        Group {
                            if let image = uiProfileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .onTapGesture {
                                if uiProfileImage != nil {
                                    showImagePreview = true
                                }
                            }
                        Button {
                            showImageOptions = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .buttonStyle(.plain)
                        .offset(x: -6, y: -6)
                    }

                    Text(profileVM.username.isEmpty ? "User" : profileVM.username)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section("Account Info") {

                    if let email = AuthVM.user?.email {
                        infoRow(
                            title: "Email",
                            value: email,
                        )
                    }

                    infoRow(
                        title: "Username",
                        value: profileVM.username.isEmpty ? "Add username" : profileVM.username,
                        isPlaceholder: profileVM.username.isEmpty
                    )

                }

                Section("App") {
                    
                    NavigationLink{
                        SettingsView()
                    }label: {
                     Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                        Text("Settings")
                    }
                    
                    NavigationLink{
                        //view to come later
                       Text("not implemented yet")
                    } label: {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }

                }

                Section("Account") {
                    
                    NavigationLink {
                        ChangePasswordView()
                    } label: {
                        Label("Change Password", systemImage: "lock")
                    }

                    Button{
                        showLogoutAlert = true
                    }label: {
                        HStack{
                            Image(systemName: "arrow.backward.square")
                            Text("Logout")
                        }
                    }
                }

                Section {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)

                        Text("Delete Account")
                            .foregroundColor(.red)

                        Spacer()
                    }
                } header: {
                    Text("Danger Zone")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .toolbar{
                Button("Edit"){
                    showEditProfile = true
                }
            }
            .sheet(isPresented: $showEditProfile){
                EditProfileView(profileVM: profileVM)
            }
            .confirmationDialog(
                "Profile Photo",
                isPresented: $showImageOptions,
                titleVisibility: .visible
            ) {
                    Button("Take Photo") {
                        showCamera = true
                    }
                
                Button("Choose from Gallery") {
                    showGalleryPicker = true
                }

                if uiProfileImage != nil {
                    Button("Remove Photo", role: .destructive) {
                       showRemovePhotoAlert = true
                    }
                }
            }
            .photosPicker(
                isPresented: $showGalleryPicker,
                selection: $selectedPhoto,
                matching: .images
            )
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    uiProfileImage = image
                    profileVM.saveProfileImage(image)
                }
            }
            .fullScreenCover(isPresented: $showImagePreview) {
                ProfileImagePreview(
                    image: uiProfileImage,
                    isPresented: $showImagePreview
                )
            }
            
            .onAppear {
                       uiProfileImage = profileVM.profileImage
                   }
                   .onChange(of: selectedPhoto) { _, newItem in
                       guard let newItem else { return }

                       Task {
                           if let data = try? await newItem.loadTransferable(type: Data.self),
                            let image = UIImage(data: data) {

                            await MainActor.run {
                                uiProfileImage = image
                                profileVM.saveProfileImage(image)
                               }
                           }
                       }
                   }
            
            .alert("Logout", isPresented: $showLogoutAlert) {
                
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    AuthVM.signOut()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            
            // this is alert when you remove profile photo
            .alert(
                "Remove Profile Photo",
                isPresented: $showRemovePhotoAlert
            ) {
                Button("Cancel", role: .cancel) {}

                Button("Remove", role: .destructive) {
                    profileVM.deleteProfileImage()
                    uiProfileImage = nil
                }
            } message: {
                Text("Are you sure you want to remove your profile photo?")
            }

        }
    }

   func infoRow(
        title: String,
        value: String,
        isPlaceholder: Bool = false
    ) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .foregroundColor(isPlaceholder ? .secondary : .primary)
        }
    }

    func navigationRow(
        icon: String,
        title: String,
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)

            Text(title)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ProfileImageEntity.self
    )

    ProfileView(context: container.mainContext)
        .environmentObject(AuthViewModel())
}
