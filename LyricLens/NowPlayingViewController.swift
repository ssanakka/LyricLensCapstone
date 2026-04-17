//
//  NowPlayingViewController.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit
import MediaPlayer

class NowPlayingViewController: UIViewController {

    // MARK: - Types
    private struct TimedLyric {
        let timeSeconds: Double
        let text: String
    }

    // MARK: - Outlets
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsTextView: UITextView!

    // MARK: - Properties
    private var timedLyrics: [TimedLyric] = []
    private var syncTimer: Timer?
    private var currentHighlightedIndex: Int = -1
    private var lastSpotifyTrack: String = ""

    private var autoDetectTimer: Timer?
    private var lastCheckedSong: String = ""
    private var isAutoDetectEnabled: Bool = true
    private var isSpotifyActive: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        lyricsTextView.isEditable = false
        lyricsTextView.isSelectable = false

        if UserDefaults.standard.object(forKey: "autoDetectEnabled") == nil {
            isAutoDetectEnabled = true
            UserDefaults.standard.set(true, forKey: "autoDetectEnabled")
        } else {
            isAutoDetectEnabled = UserDefaults.standard.bool(forKey: "autoDetectEnabled")
        }

        if isAutoDetectEnabled {
            lyricsTextView.text = "Waiting for music to play...\n\n🎵 Play a song in Apple Music and lyrics will appear automatically!\n\nYou can also use the Search tab to find lyrics manually."

            MPMediaLibrary.requestAuthorization { status in
                if status == .authorized {
                    print("✅ Media access authorized")
                    DispatchQueue.main.async {
                        self.startMonitoringMusic()
                    }
                } else {
                    print("❌ Media access denied")
                    DispatchQueue.main.async {
                        self.lyricsTextView.text = "Please allow media access in Settings to enable auto-detect.\n\nGo to Settings → LyricLens → Media Library → Allow"
                    }
                }
            }
        } else {
            lyricsTextView.text = "Auto-detect is OFF.\n\nUse the Search tab to find lyrics manually."
        }
    }

    // MARK: - Auto Detect

    func setAutoDetectEnabled(_ enabled: Bool) {
        isAutoDetectEnabled = enabled
        print("Auto-detect set to: \(enabled)")

        if !enabled {
            DispatchQueue.main.async {
                self.lyricsTextView.text = "Auto-detect is OFF.\n\nUse the Search tab to find lyrics manually."
            }
            autoDetectTimer?.invalidate()
            autoDetectTimer = nil
        } else {
            DispatchQueue.main.async {
                self.lyricsTextView.text = "Auto-detect is ON.\n\nPlay a song to see lyrics automatically!"
            }
            MPMediaLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.startMonitoringMusic()
                    }
                }
            }
        }
    }

    // MARK: - Lyrics Parsing

    private func parseTimedLyrics(_ syncedLyrics: String) -> [TimedLyric] {
        var result: [TimedLyric] = []
        let pattern = "\\[(\\d{2}):(\\d{2})\\.(\\d{2})\\](.*?)(?=\\[|$)"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let range = NSRange(syncedLyrics.startIndex..., in: syncedLyrics)
            let matches = regex.matches(in: syncedLyrics, range: range)

            for match in matches {
                if let mRange = Range(match.range(at: 1), in: syncedLyrics),
                   let sRange = Range(match.range(at: 2), in: syncedLyrics),
                   let csRange = Range(match.range(at: 3), in: syncedLyrics),
                   let textRange = Range(match.range(at: 4), in: syncedLyrics) {

                    let minutes = Double(syncedLyrics[mRange]) ?? 0
                    let seconds = Double(syncedLyrics[sRange]) ?? 0
                    let centiseconds = Double(syncedLyrics[csRange]) ?? 0
                    let totalSeconds = minutes * 60 + seconds + centiseconds / 100.0

                    let text = String(syncedLyrics[textRange])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: " ")
                        .trimmingCharacters(in: .whitespaces)

                    if !text.isEmpty {
                        result.append(TimedLyric(timeSeconds: totalSeconds, text: text))
                    }
                }
            }
        } catch {
            print("Regex error: \(error)")
        }

        return result.sorted { $0.timeSeconds < $1.timeSeconds }
    }

    // MARK: - Display Lyrics

    func displayCleanLyrics(from syncedLyrics: String?, plainLyrics: String?, instrumental: Bool) {
        stopSyncTimer()
        timedLyrics = []
        currentHighlightedIndex = -1

        if instrumental {
            lyricsTextView.text = "🎵 This track is instrumental - no lyrics available 🎵"
            return
        }

        if let synced = syncedLyrics, !synced.isEmpty {
            let timed = parseTimedLyrics(synced)
            if !timed.isEmpty {
                timedLyrics = timed
                print("✅ Loaded \(timed.count) timed lyric lines")

                if isSpotifyActive {
                    startSyncTimer()
                } else {
                    // Display plain styled text, no gray highlighting
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 8
                    paragraphStyle.alignment = .center
                    let attrs: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont(name: "HiraginoSans-W8", size: 25) ?? UIFont.systemFont(ofSize: 25),
                        .paragraphStyle: paragraphStyle
                    ]
                    let fullText = timed.map { $0.text }.joined(separator: "\n\n")
                    lyricsTextView.attributedText = NSAttributedString(string: fullText, attributes: attrs)
                }
                lyricsTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                return
            }
        }

        if let plain = plainLyrics, !plain.isEmpty {
            lyricsTextView.text = plain
            lyricsTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
            return
        }

        lyricsTextView.text = "No lyrics found for this song."
    }

    // MARK: - Music Detection (Apple Music)

    private func startMonitoringMusic() {
        autoDetectTimer?.invalidate()
        autoDetectTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkNowPlaying()
        }
    }

    private func checkNowPlaying() {
        if isSpotifyActive || !isAutoDetectEnabled { return }

        let player = MPMusicPlayerController.systemMusicPlayer

        guard let nowPlayingItem = player.nowPlayingItem else {
            if lastCheckedSong != "" {
                lastCheckedSong = ""
                DispatchQueue.main.async {
                    self.lyricsTextView.text = "No music playing.\n\n🎵 Play a song to see lyrics automatically!"
                    self.songTitleLabel.text = "Song Title"
                    self.artistNameLabel.text = "Artist Name"
                    self.albumArtImageView.image = nil
                }
            }
            return
        }

        let trackName = nowPlayingItem.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "Unknown"
        let artistName = nowPlayingItem.value(forProperty: MPMediaItemPropertyArtist) as? String ?? "Unknown"

        var currentArtworkImage: UIImage? = nil
        if let artwork = nowPlayingItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            currentArtworkImage = artwork.image(at: CGSize(width: 300, height: 300))
        }

        let songID = "\(trackName)-\(artistName)"

        DispatchQueue.main.async {
            if let image = currentArtworkImage {
                self.albumArtImageView.image = image
            }
            self.songTitleLabel.text = trackName
            self.artistNameLabel.text = artistName
        }

        if songID != lastCheckedSong && trackName != "Unknown" {
            lastCheckedSong = songID

            DispatchQueue.main.async {
                self.lyricsTextView.text = "Fetching lyrics for \(trackName)..."
            }

            let searchQuery = "\(artistName) \(trackName)"

            LRCLIBAPIService.shared.searchLyrics(query: searchQuery) { [weak self] results in
                DispatchQueue.main.async {
                    if let firstResult = self?.findBestMatch(from: results, trackName: trackName, artistName: artistName) {
                        let instrumental = firstResult["instrumental"] as? Bool ?? false
                        let syncedLyrics = firstResult["syncedLyrics"] as? String
                        let plainLyrics = firstResult["plainLyrics"] as? String
                        self?.displayCleanLyrics(from: syncedLyrics, plainLyrics: plainLyrics, instrumental: instrumental)
                    } else {
                        self?.lyricsTextView.text = "No lyrics found for '\(trackName)' by \(artistName)"
                    }
                }
            }
        }
    }

    // MARK: - Called from Search Screen

    func displayLyricsFromDict(trackName: String?, artistName: String?, instrumental: Bool, syncedLyrics: String?, plainLyrics: String?) {
        if let track = trackName { songTitleLabel.text = track }
        if let artist = artistName { artistNameLabel.text = artist }
        displayCleanLyrics(from: syncedLyrics, plainLyrics: plainLyrics, instrumental: instrumental)
    }

    // MARK: - Spotify

    func fetchLyricsForSpotifyTrack(trackName: String, artistName: String) {
        let trackID = "\(trackName)-\(artistName)"
        guard trackID != lastSpotifyTrack else {
            print("⏭️ Same Spotify track, skipping refetch")
            return
        }
        lastSpotifyTrack = trackID
        
        stopSyncTimer()
        lyricsTextView.text = "Fetching lyrics for \(trackName)..."

        let searchQuery = "\(artistName) \(trackName)"

        LRCLIBAPIService.shared.searchLyrics(query: searchQuery) { [weak self] results in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let firstResult = self.findBestMatch(from: results, trackName: trackName, artistName: artistName) {
                    let instrumental = firstResult["instrumental"] as? Bool ?? false
                    let syncedLyrics = firstResult["syncedLyrics"] as? String
                    let plainLyrics = firstResult["plainLyrics"] as? String
                    self.displayCleanLyrics(from: syncedLyrics, plainLyrics: plainLyrics, instrumental: instrumental)
                } else {
                    self.lyricsTextView.text = "No lyrics found for '\(trackName)' by \(artistName)"
                }
            }
        }
    }

    func fetchAlbumArtForSpotifyTrack(trackName: String, artistName: String) {
        let searchQuery = "\(trackName) \(artistName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(searchQuery)&limit=1&entity=song"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid album art URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("❌ Album art fetch error: \(error?.localizedDescription ?? "unknown")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let artworkURLString = firstResult["artworkUrl100"] as? String,
                   let artworkURL = URL(string: artworkURLString) {

                    URLSession.shared.dataTask(with: artworkURL) { imageData, _, _ in
                        if let imageData = imageData, let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self?.albumArtImageView.image = image
                                print("✅ Album art loaded for: \(trackName)")
                            }
                        }
                    }.resume()
                }
            } catch {
                print("❌ Album art parsing error: \(error)")
            }
        }.resume()
    }

    func setSpotifyMode(enabled: Bool) {
        isSpotifyActive = enabled
        print("🎵 Spotify mode: \(enabled ? "ON" : "OFF")")

        if enabled {
            autoDetectTimer?.invalidate()
            autoDetectTimer = nil
            if !timedLyrics.isEmpty {
                startSyncTimer()
            }
        } else {
            stopSyncTimer()
            currentHighlightedIndex = -1
            lastSpotifyTrack = ""
        }
    }

    func setAppleMusicMode(enabled: Bool) {
        print("🎵 Apple Music mode: \(enabled ? "ON" : "OFF")")
        if enabled && isAutoDetectEnabled {
            startMonitoringMusic()
        } else if !enabled {
            autoDetectTimer?.invalidate()
            autoDetectTimer = nil
        }
    }

    func clearAlbumArt() {
        DispatchQueue.main.async {
            self.albumArtImageView.image = nil
        }
    }

    // MARK: - Lyric Sync

    private func startSyncTimer() {
        stopSyncTimer()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateLyricSync()
        }
    }

    private func stopSyncTimer() {
        syncTimer?.invalidate()
        syncTimer = nil
        
        // Reset to plain white text if we have lyrics loaded
        guard !timedLyrics.isEmpty else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HiraginoSans-W8", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .paragraphStyle: paragraphStyle
        ]
        let fullText = timedLyrics.map { $0.text }.joined(separator: "\n\n")
        DispatchQueue.main.async {
            self.lyricsTextView.attributedText = NSAttributedString(string: fullText, attributes: attrs)
        }
    }

    private func updateLyricSync() {
        guard isSpotifyActive, !timedLyrics.isEmpty else { return }

        let positionSeconds = SpotifyManager.shared.estimatedPlaybackPosition()

        var currentIndex = 0
        for (i, lyric) in timedLyrics.enumerated() {
            if lyric.timeSeconds <= positionSeconds {
                currentIndex = i
            } else {
                break
            }
        }

        if currentIndex != currentHighlightedIndex {
            currentHighlightedIndex = currentIndex
            highlightAndScrollToLyric(at: currentIndex)
        }
    }

    private func highlightAndScrollToLyric(at index: Int) {
        guard !timedLyrics.isEmpty else { return }

        let fullText = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center

        for (i, lyric) in timedLyrics.enumerated() {
            let isActive = i == index
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: isActive ? UIColor.white : UIColor.gray,
                .font: isActive ? UIFont(name: "HiraginoSans-W8", size: 25) ?? UIFont.boldSystemFont(ofSize: 25)
                          : UIFont(name: "HiraginoSans-W8", size: 25) ?? UIFont.systemFont(ofSize: 25),
                .paragraphStyle: paragraphStyle
            ]
            fullText.append(NSAttributedString(string: lyric.text, attributes: attrs))
            if i < timedLyrics.count - 1 {
                fullText.append(NSAttributedString(string: "\n\n"))
            }
        }

        lyricsTextView.attributedText = fullText

        let precedingText = timedLyrics.prefix(index).map { $0.text }.joined(separator: "\n\n")
        let charOffset = precedingText.isEmpty ? 0 : precedingText.count + 2
        let range = NSRange(location: charOffset, length: timedLyrics[index].text.count)
        guard let start = lyricsTextView.position(from: lyricsTextView.beginningOfDocument, offset: range.location),
              let end = lyricsTextView.position(from: start, offset: range.length),
              let textRange = lyricsTextView.textRange(from: start, to: end) else { return }

        let lineRect = lyricsTextView.firstRect(for: textRange)
        let targetOffset = lineRect.origin.y - lyricsTextView.textContainerInset.top
        let maxOffset = lyricsTextView.contentSize.height - lyricsTextView.bounds.height
        let clampedOffset = min(max(targetOffset, 0), maxOffset)

        lyricsTextView.setContentOffset(CGPoint(x: 0, y: clampedOffset), animated: true)
    }
    
    private func findBestMatch(from results: [[String: Any]], trackName: String, artistName: String) -> [String: Any]? {
        let normalizedTrack = trackName.lowercased().trimmingCharacters(in: .whitespaces)
        let normalizedArtist = artistName.lowercased().trimmingCharacters(in: .whitespaces)
        
        // First try exact match on both track and artist
        if let exact = results.first(where: {
            let t = ($0["trackName"] as? String ?? "").lowercased()
            let a = ($0["artistName"] as? String ?? "").lowercased()
            return t == normalizedTrack && a == normalizedArtist
        }) {
            return exact
        }
        
        // Then try exact track name match only
        if let trackMatch = results.first(where: {
            let t = ($0["trackName"] as? String ?? "").lowercased()
            return t == normalizedTrack
        }) {
            return trackMatch
        }
        
        // No good match found
        return nil
    }
}
