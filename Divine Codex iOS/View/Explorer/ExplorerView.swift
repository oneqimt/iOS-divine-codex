//
//  ExplorerView.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import SwiftUI

/// Intermediate view shown when the user selects the Explorer tab.
/// 
/// Purpose:
/// - Set the mood and context before entering the immersive RealityKit experience.
/// - Provide information about what the Cosmology Explorer is and how to interact with it.
/// - Act as a transitional "cover" between the main app and the full-screen 3D scene.
///
/// From this view, the actual CosmologyScene will be presented using .fullScreenCover.
struct ExplorerView: View {
    
    @State private var showCosmologyScene = false
    
    var body: some View {
        ZStack {
            // Background - should feel sacred and immersive
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Hero / Logo area
                VStack(spacing: 16) {
                    Image("logo") // Using logo.jpg from Assets
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .padding(.horizontal, 40)
                    
                    Text("The Cosmology Explorer")
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    
                    Text("A living journey through the divine hierarchy")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Instructional / Mood-setting content
                VStack(alignment: .leading, spacing: 20) {
                    Text("What to Expect")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Navigate the Aeons with intuitive gestures", systemImage: "hand.tap")
                        Label("Discover the 24 Invisibles and their divine pairings", systemImage: "sparkles")
                        Label("Witness Sophia’s sacred journey of descent and return", systemImage: "arrow.up.arrow.down")
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Launch button
                Button {
                    showCosmologyScene = true
                } label: {
                    Text("Enter the Pleroma")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo) // Will likely be refined with Liquid Glass
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .fullScreenCover(isPresented: $showCosmologyScene) {
            // This is where the actual RealityKit scene will live
            CosmologyScene()
                .onDisappear {
                    // Good place for any cleanup or state reset when leaving the immersive experience
                }
        }
    }
}

#Preview {
    ExplorerView()
}
