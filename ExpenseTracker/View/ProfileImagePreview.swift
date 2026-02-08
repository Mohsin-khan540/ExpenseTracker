//
//  ProfileImagePreview.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 23/01/2026.
//

import SwiftUI

struct ProfileImagePreview: View {
    let image : UIImage?
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding()
        }

    }
}

#Preview {
    ProfileImagePreview(image: UIImage(systemName: "person.circle"), isPresented: .constant(true))
}
