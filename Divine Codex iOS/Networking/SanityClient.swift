//
//  SanityClient.swift
//  Divine Codex iOS
//
//  A minimal, home-grown HTTP client for Sanity's REST + GROQ API.
//  No external SDK — the Sanity Swift SDK is no longer maintained.
//
//  Created by Dennis Miller on 5/28/26.
//

import Foundation
import OSLog

// MARK: - Project Constants

/// Sanity project identifier (visible in the Sanity dashboard / `sanity.config.ts`).
let sanityProjectId = "56v9xtca"

/// Dataset name. We currently target production; introduce a debug/staging
/// dataset here later if needed.
let sanityDataset = "production"

/// CDN-backed image base URL. Sanity has two image hosts:
/// - `cdn.sanity.io`     → cached, faster, eventually-consistent
/// - `apicdn.sanity.io`  → API CDN, same caching semantics
/// We default to the API CDN for production; swap if you see stale images.
let sanityImageBaseURL = "https://apicdn.sanity.io/images/"

// MARK: - Logger

private let logger = Logger(
    subsystem: "com.divinecodex.DivineCodexiOS",
    category: "SanityClient"
)

// MARK: - SanityError

/// Typed errors surfaced by `SanityClient`.
/// Kept in this file because the client is the only producer.
enum SanityError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "The Sanity request URL could not be constructed."
        case .invalidResponse:     return "The server returned a non-HTTP response."
        case .httpStatus(let code): return "Sanity returned HTTP \(code)."
        case .decoding(let error): return "Failed to decode Sanity response: \(error.localizedDescription)"
        case .transport(let error): return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - SanityClientProtocol

/// Abstraction over `SanityClient` so view models can be unit-tested
/// with a fake implementation that doesn't hit the network.
protocol SanityClientProtocol: Sendable {
    /// Executes a GROQ query and decodes the `result` field as `T`.
    ///
    /// `T` is required to be `Sendable` so that `T.Type` can safely cross
    /// actor boundaries (e.g. when a `@MainActor`-isolated view model calls
    /// into a non-isolated client, or vice versa) under Swift 6's strict
    /// concurrency checking.
    func fetch<T: Decodable & Sendable>(query: String, as type: T.Type) async throws -> T
}

// MARK: - SanityResponse

/// Sanity's standard query response envelope: `{ "ms": …, "query": …, "result": … }`.
/// We only care about `result`, but decoding the whole shape keeps errors precise.
private struct SanityResponse<T: Decodable>: Decodable {
    let result: T
}

// MARK: - SanityClient

/// Concrete HTTP client. Constructs a Sanity query URL and decodes the response.
///
/// Usage:
/// ```swift
/// let client = SanityClient(projectId: sanityProjectId,
///                           dataset: sanityDataset,
///                           useCdn: true,
///                           token: TokenManager.shared.getToken())
/// let codices: [DivineCodex] = try await client.fetch(
///     query: #"*[_type == "divineCodex"]"#,
///     as: [DivineCodex].self
/// )
/// ```
struct SanityClient: SanityClientProtocol {
    let projectId: String
    let dataset: String
    /// When `true`, requests go to `apicdn.sanity.io` (cached). Use `false`
    /// in development to always see fresh data.
    let useCdn: Bool
    /// Optional bearer token. Empty string is treated as "no token".
    let token: String?
    let session: URLSession

    init(
        projectId: String,
        dataset: String,
        useCdn: Bool,
        token: String?,
        session: URLSession = .shared
    ) {
        self.projectId = projectId
        self.dataset = dataset
        self.useCdn = useCdn
        self.token = token
        self.session = session
    }

    // MARK: fetch

    func fetch<T: Decodable & Sendable>(query: String, as type: T.Type) async throws -> T {
        let url = try buildURL(for: query)
        logger.debug("SANITY GET \(url.absoluteString, privacy: .public)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger.error("SANITY transport error: \(error.localizedDescription, privacy: .public)")
            throw SanityError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw SanityError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            logger.error("SANITY HTTP \(http.statusCode, privacy: .public)")
            throw SanityError.httpStatus(http.statusCode)
        }

        do {
            let envelope = try JSONDecoder().decode(SanityResponse<T>.self, from: data)
            return envelope.result
        } catch {
            logger.error("SANITY decode error: \(error.localizedDescription, privacy: .public)")
            // Helpful for early development — print the raw payload to see what shape arrived.
            if let raw = String(data: data, encoding: .utf8) {
                logger.debug("SANITY raw payload: \(raw, privacy: .public)")
            }
            throw SanityError.decoding(error)
        }
    }

    // MARK: URL construction

    private func buildURL(for query: String) throws -> URL {
        // Sanity query endpoint:
        // https://{projectId}.api.sanity.io/v2023-01-01/data/query/{dataset}?query={groq}
        // CDN variant swaps `api` for `apicdn`.
        let host = useCdn ? "apicdn.sanity.io" : "api.sanity.io"
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(projectId).\(host)"
        components.path = "/v2023-01-01/data/query/\(dataset)"
        components.queryItems = [URLQueryItem(name: "query", value: query)]

        guard let url = components.url else {
            throw SanityError.invalidURL
        }
        return url
    }
}

#if DEBUG
/// A no-op client for SwiftUI previews and tests.
/// Returns empty results for supported types (e.g. [DivineCodex]) without
/// performing any network calls.
struct PreviewSanityClient: SanityClientProtocol {
    func fetch<T: Decodable & Sendable>(query: String, as type: T.Type) async throws -> T {
        if type == [DivineCodex].self {
            return [] as! T
        }
        throw NSError(
            domain: "preview",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "No preview data configured for \(T.self)"]
        )
    }
}

extension SanityViewModel {
    /// Convenience for previews and tests. Uses a client that never hits the network.
    static var preview: SanityViewModel {
        SanityViewModel(client: PreviewSanityClient())
    }
}
#endif
