//
//  Lyrics.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import Foundation

struct Lyrics: Decodable, @unchecked Sendable {
    let id: Int?
    let trackName: String?
    let artistName: String?
    let albumName: String?
    let duration: Int?
    let instrumental: Bool?
    let plainLyrics: String?
    let syncedLyrics: String?
}
