//
//  MusicService.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import Foundation

enum MusicService: String, Codable {
    case spotify = "spotify"
    case appleMusic = "appleMusic"
    case none = "none"
}

struct LastPlayedSong: Codable {
    let trackName: String
    let artistName: String
    let service: MusicService
}

protocol LyricsDisplayDelegate: AnyObject {
    func didSelectLyrics(trackName: String, artistName: String, syncedLyrics: String?, plainLyrics: String?, instrumental: Bool, albumArt: UIImage?)
}
