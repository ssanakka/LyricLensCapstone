//
//  NowPlayingViewController.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit

class NowPlayingViewController: UIViewController {
    
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Now Playing"
        lyricsTextView.isEditable = false
        lyricsTextView.isSelectable = false
        lyricsTextView.text = "Waiting for music to play...\n\nLyrics will appear here when you search for a song."
    }
    
    func displayLyricsFromDict(trackName: String?, artistName: String?, instrumental: Bool, syncedLyrics: String?, plainLyrics: String?) {
        if instrumental {
            lyricsTextView.text = "🎵 This track is instrumental - no lyrics available 🎵"
            return
        }
        
        if let synced = syncedLyrics, !synced.isEmpty {
            lyricsTextView.text = synced
        } else if let plain = plainLyrics, !plain.isEmpty {
            lyricsTextView.text = plain
        } else {
            lyricsTextView.text = "No lyrics found for this song."
        }
        
        if let track = trackName {
            songTitleLabel.text = track
        }
        if let artist = artistName {
            artistNameLabel.text = artist
        }
    }
}
