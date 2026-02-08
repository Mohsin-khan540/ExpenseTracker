//
//  ThemeSelectionView.swift
//  ExpenseTracker
//
//  Created by Mohsin khan on 02/01/2026.
//

import SwiftUI

struct ThemeSelectionView: View {
    @AppStorage(AppSettings.appThemeKey)
    private var appTheme : AppTheme = .system
    var body: some View {
        List{
            ForEach(AppTheme.allCases){ theme in
                HStack{
                    Text(theme.title)
                    Spacer()
                    if theme == appTheme {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                    
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    appTheme = theme
                }
            }
        }
    }
}

#Preview {
    ThemeSelectionView()
}
