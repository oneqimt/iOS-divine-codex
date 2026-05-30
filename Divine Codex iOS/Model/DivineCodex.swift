//
//  DivineCodex.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import Foundation

// MARK: - DivineCodex
//
// All of these model types are pure value types and are safe to share across
// concurrency domains. `DivineCodex`'s `Codable` conformance is declared in a
// `nonisolated` extension so callers in any isolation domain (including
// `@MainActor` view models) can use it to satisfy `Sendable`-constrained
// generics like `SanityClient.fetch(query:as:)`.

struct DivineCodex: Identifiable, Sendable {
    let id: String
    let title: String?
    let slug: Slug
    let image: SanityImage?
    let description: [PortableTextBlock]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case slug
        case image
        case description = "body"   // Sanity uses "body" for portable text
    }
}

struct Slug: Codable, Sendable {
    let current: String
    let type: String?

    enum CodingKeys: String, CodingKey {
        case current
        case type = "_type"
    }
}

struct SanityImage: Codable, Sendable {
    let asset: AssetReference
    let caption: String?
}

struct AssetReference: Codable, Sendable {
    let _ref: String

    enum CodingKeys: String, CodingKey {
        case _ref
    }
}

struct PortableTextBlock: Codable, Sendable {
    let _type: String
    let style: String?
    let children: [TextSpan]?
    let asset: AssetReference?
    let caption: String?
    let _key: String // Required for ForEach identity and matches Sanity payloads.

    enum CodingKeys: String, CodingKey {
        case _type
        case style
        case children
        case asset
        case caption
        case _key
    }
}

struct TextSpan: Codable, Sendable {
    let _type: String
    let text: String
    let marks: [String]?   // ✅ optional, since Sanity omits when empty
}

struct ImageSource: Identifiable, Sendable {
    let id = UUID()
    let assetRef: String
    let caption: String?
    let type: String
}

// MARK: - Nonisolated Codable conformance for the top-level decoded type.
//
// Only `DivineCodex` needs this because it's the type passed to
// `SanityClient.fetch(query:as:)`, whose generic is `T: Decodable & Sendable`.
// The nested types are reached transitively and don't need the explicit
// nonisolated conformance.

nonisolated extension DivineCodex: Codable {}
