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

    /// All `DivineCodex` documents currently loaded.
    var codices: [DivineCodex] = []

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

    /// Fetches every `divineCodex` document from Sanity, ordered by title.
    /// Updates `codices` on success or `errorMessage` on failure.
    func fetchCodices() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // GROQ: every divineCodex, ordered alphabetically by title.
        let query = #"*[_type == "divineCodex"] | order(title asc)"#

        do {
            let results = try await client.fetch(query: query, as: [DivineCodex].self)
            codices = results
            logger.info("Fetched \(results.count, privacy: .public) codices.")
            // Early-development visibility — remove once we render in a view.
            print("✅ Fetched \(results.count) codices:")
            for codex in results {
                print(" • \(codex.title ?? "(untitled)") — slug: \(codex.slug.current)")
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            errorMessage = message
            logger.error("fetchCodices failed: \(message, privacy: .public)")
            print("❌ fetchCodices failed: \(message)")
        }
    }
}
