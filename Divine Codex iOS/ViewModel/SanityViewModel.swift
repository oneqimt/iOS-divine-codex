//
//  SanityViewModel.swift
//  Divine Codex
//
//  Owns the app-wide Sanity-backed state. Injected into the SwiftUI
//  environment from `Divine_Codex_iOSApp`.
//
//  Created by Dennis Miller on 5/30/26.
//

import Foundation
import OSLog

private let logger = Logger(
    subsystem: "com.divinecodex.DivineCodexiOS",
    category: "SanityViewModel"
)

/// Drives content loaded from Sanity. Uses the new `@Observable` macro so
/// SwiftUI views can read individual properties without `@Published` plumbing.
///
/// The view model takes a `SanityClientProtocol` so unit tests can inject a
/// fake client that returns canned data without hitting the network.
@Observable
@MainActor
final class SanityViewModel {

    // MARK: State

    /// All `emanation` nodes currently loaded (Monad, Pleroma, Aeons).
    /// This is the flat list as returned from Sanity; the node tree is
    /// reassembled elsewhere from `parentId` / `consortId`.
    var emanations: [Emanation] = []

    /// Sacred Frequencies — chants and utterances for the practice player.
    var frequencies: [Frequency] = []

    /// `true` while a network request is in flight.
    var isLoading: Bool = false

    /// Human-readable error from the last failed request, if any.
    var errorMessage: String?

    // MARK: Dependencies

    private let client: SanityClientProtocol

    // MARK: Init

    init(client: SanityClientProtocol) {
        self.client = client
    }

    // MARK: Queries

    /// Fetches every `emanation` node from Sanity, ordered by `order`.
    /// Updates `emanations` on success or `errorMessage` on failure.
    func fetchEmanations() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let startTime = Date()
        // GROQ: every emanation, ordered by traditional sequence. References
        // are flattened to ids (`parentId`, `consortId`) and the type name is
        // projected so the tree can be rebuilt in Swift. See IN_PROGRESS.md.
        let query = """
        *[_type == "emanation"] | order(order asc){
          _id, name, "slug": slug.current, gender, order,
          "type": emanationType->name,
          "parentId": parent._ref,
          "consortId": consort._ref,
          explorer{ layerOrder, position, color, scale, isVisibleByDefault, geometryHint },
          shortDescription, description, media, video
        }
        """

        do {
            let results = try await client.fetch(query: query, as: [Emanation].self)
            emanations = results
            let elapsed = Date().timeIntervalSince(startTime)
            logger.info("Fetched \(results.count, privacy: .public) emanations in \(elapsed, privacy: .public)s.")
            print("✅ Fetched \(results.count) emanations in \(String(format: "%.2f", elapsed))s:")
            for emanation in results {
                print(" • \(emanation.name ?? "(unnamed)") — type: \(emanation.type ?? "?"), parent: \(emanation.parentId ?? "none")")
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            errorMessage = message
            logger.error("fetchEmanations failed: \(message, privacy: .public)")
            print("❌ fetchEmanations failed: \(message)")
        }
    }

    /// Fetches every `frequency` document for the Sacred Frequencies player.
    func fetchFrequencies() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let query = """
        *[_type == "frequency"] | order(coalesce(order, 9999) asc){
          _id,
          "title": coalesce(title, name),
          "slug": slug.current,
          "shortDescription": coalesce(shortDescription, phoneticSequence),
          "practiceNotes": coalesce(practiceNotes, notes),
          "pronunciationGuide": coalesce(pronunciationGuide, phoneticSequence),
          order,
          "audioUrl": coalesce(audio.url, audioUrl),
          "audioLoopable": coalesce(audio.loopable, true),
          coverImage,
          "associatedEmanationIds": associatedEmanations[]._ref
        }
        """

        do {
            let results = try await client.fetch(query: query, as: [Frequency].self)
            frequencies = results
            logger.info("Fetched \(results.count, privacy: .public) frequencies.")
            print("✅ Fetched \(results.count) frequencies")
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            errorMessage = message
            logger.error("fetchFrequencies failed: \(message, privacy: .public)")
            print("❌ fetchFrequencies failed: \(message)")
        }
    }
}
