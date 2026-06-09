//
//  Frequency.swift
//  Divine Codex iOS
//
//  A sacred utterance, chant, or meditation sound from Sanity (`frequency`
//  documents). Powers the Sacred Frequencies player — the app's primary
//  practice / personalization feature.
//

import Foundation

struct Frequency: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let title: String?
    let slug: String?
    let shortDescription: String?
    let practiceNotes: String?
    let pronunciationGuide: String?
    let order: Int?
    /// Externally hosted audio (MP3, AAC, or HLS). Sanity stores the URL only.
    let audioURL: String?
    let audioLoopable: Bool?
    let coverImage: SanityImage?
    /// Optional muted hero loop (MP4 from R2). Replaces cover image when set.
    let coverVideoURL: String?
    /// Flattened emanation refs for linking practice to the cosmology map.
    let associatedEmanationIds: [String]?

    var displayTitle: String { title ?? "Untitled Frequency" }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case slug
        case shortDescription
        case practiceNotes
        case pronunciationGuide
        case order
        case audioURL = "audioUrl"
        case audioLoopable
        case coverImage
        case coverVideoURL = "coverVideoUrl"
        case associatedEmanationIds
    }
}

nonisolated extension Frequency: Codable {}

#if DEBUG
extension Frequency {
    static let sampleSet: [Frequency] = [
        Frequency(
            id: "sample-frequency-vowels",
            title: "Primordial Vowels",
            slug: "primordial-vowels",
            shortDescription: "The five sacred vowels — doorways of sound into remembrance.",
            practiceNotes: "Chant slowly. One breath per vowel: i · e · o · u · a. Let each tone resonate in the chest before moving to the next.",
            pronunciationGuide: "ee · eh · oh · oo · ah",
            order: 1,
            audioURL: nil,
            audioLoopable: true,
            coverImage: nil,
            coverVideoURL: nil,
            associatedEmanationIds: ["sample-monad"]
        ),
        Frequency(
            id: "sample-frequency-i-am",
            title: "I AM THAT I AM",
            slug: "i-am-that-i-am",
            shortDescription: "The name beyond names — a thread of divine self-recognition.",
            practiceNotes: "Repeat with inward attention, not performance. Allow silence between each phrase.",
            pronunciationGuide: "eh-YEH ah-SHER eh-YEH",
            order: 2,
            audioURL: nil,
            audioLoopable: true,
            coverImage: nil,
            coverVideoURL: nil,
            associatedEmanationIds: ["sample-sophia"]
        )
    ]
}
#endif