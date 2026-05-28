//
//  DivineCodex.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import Foundation

struct DivineCodex: Identifiable, Codable {
    let id: String
    let title: String?
    let slug: Slug
    let image: SanityImage?
    let description: [PortableTextBlock]?
    
}

struct Slug: Codable {
    let current: String
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case current
        case type = "_type"
    }
}

struct SanityImage: Codable {
    let asset: AssetReference
    let caption: String?
}

struct AssetReference: Codable {
    let _ref: String
    enum CodingKeys: String, CodingKey {
        case _ref
    }
}

struct PortableTextBlock: Codable {
    let _type: String
    let style: String?
    let children: [TextSpan]?
    let asset: AssetReference?
    let caption: String?
    let _key: String // Re-added for ForEach and Sanity data
    
    enum CodingKeys: String, CodingKey {
        case _type
        case style
        case children
        case asset
        case caption
        case _key
    }
}
struct TextSpan: Codable {
    let _type: String
    let text: String
    let marks: [String]
}

struct ImageSource: Identifiable {
    let id = UUID()
    let assetRef: String
    let caption: String?
    let type: String
}
