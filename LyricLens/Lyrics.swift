//
//  Lyrics.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import Foundation

struct Lyrics: Codable {
    let id: Int?
    let trackName: String?
    let artistName: String?
    let albumName: String?
    let duration: Double?
    let instrumental: Bool?
    let plainLyrics: String?
    let syncedLyrics: String?
}
