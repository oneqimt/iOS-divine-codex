//
//  HomeView.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI

/// The main entry point / hub for the app.
/// 
/// This view will eventually contain:
/// - A sacred hero moment using the logo
/// - Brief, contemplative copy
/// - The custom Liquid Glass Tab Bar at the bottom
/// - Navigation logic to other primary destinations (Explorer, Search, Settings)
///
/// Note: The Cosmology Explorer is not launched directly from here.
/// Tapping the Explorer tab will first go to ExplorerView (a transitional screen),
/// which then presents the full RealityKit experience via .fullScreenCover.
struct HomeView: View {
    
    // Temporary state for the tab bar (will be replaced when we build the real TabBarView)
    @State private var selectedTab: MainTab = .home
    
    var body: some View {
        ZStack {
            // Background - deep cosmic dark, aligned with Liquid Glass + website
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Hero Area
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo - using logo.jpg from Assets
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 12) {
                        Text("The Divine Codex")
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .foregroundStyle(.white)
                        
                        Text("Ancient wisdom reawakened.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    Spacer()
                }
                
                // Tab Bar Placeholder
                // This will be replaced with the real custom Liquid Glass TabBarView
                TabBarPlaceholder(selectedTab: $selectedTab)
                    .padding(.bottom, 8)
            }
        }
    }
}

// Temporary placeholder for the tab bar while we build the real one
private struct TabBarPlaceholder: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                    // Click handlers will be wired up after the real TabBar is built
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20))
                        Text(tab.title)
                            .font(.caption2)
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }
}

enum MainTab: CaseIterable {
    case home
    case explorer
    case search
    case settings
    
    var title: String {
        switch self {
        case .home:     return "Home"
        case .explorer: return "Explorer"
        case .search:   return "Search"
        case .settings: return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:     return "house.fill"
        case .explorer: return "sparkles"
        case .search:   return "magnifyingglass"
        case .settings: return "gear"
        }
    }
}

#Preview {
    HomeView()
}
