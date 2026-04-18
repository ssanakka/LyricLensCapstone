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

    private var userIsScrolling: Bool = false
    private var scrollReturnTimer: Timer?

    private let lastPlayedSongKey = "lastPlayedSong"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        lyricsTextView.isEditable = false
        lyricsTextView.isSelectable = false
        lyricsTextView.delegate = self

        if UserDefaults.standard.object(forKey: "autoDetectEnabled") == nil {
            isAutoDetectEnabled = true
            UserDefaults.standard.set(true, forKey: "autoDetectEnabled")
        } else {
            isAutoDetectEnabled = UserDefaults.standard.bool(forKey: "autoDetectEnabled")
        }

        restoreLastPlayedSong()

        if isAutoDetectEnabled {
            lyricsTextView.text = "Waiting for music to play...\n\n🎵 Play a song in Apple Music and lyrics will appear automatically!\n\nYou can also use the Search tab to find lyrics manually."

            MPMediaLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async { self.startMonitoringMusic() }
                } else {
                    DispatchQueue.main.async {
                        self.lyricsTextView.text = "Please allow media access in Settings to enable auto-detect.\n\nGo to Settings → LyricLens → Media Library → Allow"
                    }
                }
            }
        } else {
            lyricsTextView.text = "Auto-detect is OFF.\n\nUse the Search tab to find lyrics manually."
        }
    }

    // MARK: - Persistence

    private func saveLastPlayedSong(trackName: String, artistName: String, service: MusicService) {
        let song = LastPlayedSong(trackName: trackName, artistName: artistName, service: service)
        if let encoded = try? JSONEncoder().encode(song) {
            UserDefaults.standard.set(encoded, forKey: lastPlayedSongKey)
        }
    }

    private func restoreLastPlayedSong() {
        guard let data = UserDefaults.standard.data(forKey: lastPlayedSongKey),
              let song = try? JSONDecoder().decode(LastPlayedSong.self, from: data) else { return }
        songTitleLabel.text = song.trackName
        artistNameLabel.text = song.artistName
    }

    // MARK: - Auto Detect

    func setAutoDetectEnabled(_ enabled: Bool) {
        isAutoDetectEnabled = enabled

        if !enabled {
            lyricsTextView.text = "Auto-detect is OFF.\n\nUse the Search tab to find lyrics manually."
            autoDetectTimer?.invalidate()
            autoDetectTimer = nil
        } else {
            lyricsTextView.text = "Auto-detect is ON.\n\nPlay a song to see lyrics automatically!"
            MPMediaLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async { self.startMonitoringMusic() }
                }
            }
        }
    }

    // MARK: - Lyrics Parsing

    private func parseTimedLyrics(_ syncedLyrics: String) -> [TimedLyric] {
        var result: [TimedLyric] = []
        let pattern = "\\[(\\d{2}):(\\d{2})\\.(\\d{2})\\](.*?)(?=\\[|$)"
        let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
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

                if isSpotifyActive {
                    startSyncTimer()
                } else {
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

    // MARK: - Best Match Helper

    private func findBestMatch(from results: [Lyrics], trackName: String, artistName: String) -> Lyrics? {
        let normalizedTrack = trackName.lowercased().trimmingCharacters(in: .whitespaces)
        let normalizedArtist = artistName.lowercased().trimmingCharacters(in: .whitespaces)

        if let exact = results.first(where: {
            ($0.trackName ?? "").lowercased() == normalizedTrack &&
            ($0.artistName ?? "").lowercased() == normalizedArtist
        }) { return exact }

        if let trackMatch = results.first(where: {
            ($0.trackName ?? "").lowercased() == normalizedTrack
        }) { return trackMatch }

        return nil
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
                lyricsTextView.text = "No music playing.\n\n🎵 Play a song to see lyrics automatically!"
                songTitleLabel.text = "Song Title"
                artistNameLabel.text = "Artist Name"
                albumArtImageView.image = nil
            }
            return
        }

        let trackName = nowPlayingItem.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "Unknown"
        let artistName = nowPlayingItem.value(forProperty: MPMediaItemPropertyArtist) as? String ?? "Unknown"

        if let artwork = nowPlayingItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            albumArtImageView.image = artwork.image(at: CGSize(width: 300, height: 300))
        }

        songTitleLabel.text = trackName
        artistNameLabel.text = artistName

        let songID = "\(trackName)-\(artistName)"

        if songID != lastCheckedSong && trackName != "Unknown" {
            lastCheckedSong = songID
            saveLastPlayedSong(trackName: trackName, artistName: artistName, service: .appleMusic)
            lyricsTextView.text = "Fetching lyrics for \(trackName)..."

            LRCLIBAPIService.shared.searchLyrics(query: "\(artistName) \(trackName)") { [weak self] results in
                guard let self = self else { return }
                if let match = self.findBestMatch(from: results, trackName: trackName, artistName: artistName) {
                    self.displayCleanLyrics(from: match.syncedLyrics, plainLyrics: match.plainLyrics, instrumental: match.instrumental ?? false)
                } else {
                    self.lyricsTextView.text = "No lyrics found for '\(trackName)' by \(artistName)"
                }
            }
        }
    }

    // MARK: - Spotify

    func fetchLyricsForSpotifyTrack(trackName: String, artistName: String) {
        let trackID = "\(trackName)-\(artistName)"
        guard trackID != lastSpotifyTrack else { return }
        lastSpotifyTrack = trackID
        saveLastPlayedSong(trackName: trackName, artistName: artistName, service: .spotify)

        stopSyncTimer()
        lyricsTextView.text = "Fetching lyrics for \(trackName)..."

        LRCLIBAPIService.shared.searchLyrics(query: "\(artistName) \(trackName)") { [weak self] results in
            guard let self = self else { return }
            if let match = self.findBestMatch(from: results, trackName: trackName, artistName: artistName) {
                self.displayCleanLyrics(from: match.syncedLyrics, plainLyrics: match.plainLyrics, instrumental: match.instrumental ?? false)
            } else {
                self.lyricsTextView.text = "No lyrics found for '\(trackName)' by \(artistName)"
            }
        }
    }

    func fetchAlbumArtForSpotifyTrack(trackName: String, artistName: String) {
        let searchQuery = "\(trackName) \(artistName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(searchQuery)&limit=1&entity=song"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let firstResult = results.first,
                  let artworkURLString = firstResult["artworkUrl100"] as? String,
                  let artworkURL = URL(string: artworkURLString) else { return }

            URLSession.shared.dataTask(with: artworkURL) { imageData, _, _ in
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.albumArtImageView.image = image
                    }
                }
            }.resume()
        }.resume()
    }

    func setSpotifyMode(enabled: Bool) {
        isSpotifyActive = enabled

        if enabled {
            autoDetectTimer?.invalidate()
            autoDetectTimer = nil
            if !timedLyrics.isEmpty { startSyncTimer() }
        } else {
            stopSyncTimer()
            currentHighlightedIndex = -1
            lastSpotifyTrack = ""
        }
    }

    func setAppleMusicMode(enabled: Bool) {
        if enabled && isAutoDetectEnabled {
            startMonitoringMusic()
        } else if !enabled {
            autoDetectTimer?.invalidate()
            autoDetectTimer = nil
        }
    }

    func clearAlbumArt() {
        albumArtImageView.image = nil
    }

    // MARK: - Lyric Sync

    private func startSyncTimer() {
        stopSyncTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateLyricSync()
        }
        syncTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateLyricSync()
        }
    }

    private func stopSyncTimer() {
        syncTimer?.invalidate()
        syncTimer = nil

        guard !timedLyrics.isEmpty else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HiraginoSans-W8", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .paragraphStyle: paragraphStyle
        ]
        lyricsTextView.attributedText = NSAttributedString(
            string: timedLyrics.map { $0.text }.joined(separator: "\n\n"),
            attributes: attrs
        )
    }

    private func updateLyricSync() {
        guard isSpotifyActive, !timedLyrics.isEmpty else { return }

        let positionSeconds = SpotifyManager.shared.estimatedPlaybackPosition()

        var currentIndex = 0
        for (i, lyric) in timedLyrics.enumerated() {
            if lyric.timeSeconds <= positionSeconds { currentIndex = i } else { break }
        }

        if currentIndex != currentHighlightedIndex {
            currentHighlightedIndex = currentIndex
            highlightAndScrollToLyric(at: currentIndex)
        }
    }

    private func highlightAndScrollToLyric(at index: Int) {
        guard !timedLyrics.isEmpty else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center

        let fullText = NSMutableAttributedString()
        for (i, lyric) in timedLyrics.enumerated() {
            let isActive = i == index
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: isActive ? UIColor.white : UIColor.gray,
                .font: UIFont(name: "HiraginoSans-W8", size: 25) ?? UIFont.systemFont(ofSize: 25),
                .paragraphStyle: paragraphStyle
            ]
            fullText.append(NSAttributedString(string: lyric.text, attributes: attrs))
            if i < timedLyrics.count - 1 {
                fullText.append(NSAttributedString(string: "\n\n"))
            }
        }

        lyricsTextView.attributedText = fullText

        guard !userIsScrolling else { return }

        let layoutManager = lyricsTextView.layoutManager
        let textContainer = lyricsTextView.textContainer

        let precedingText = timedLyrics.prefix(index).map { $0.text }.joined(separator: "\n\n")
        let charOffset = precedingText.isEmpty ? 0 : precedingText.count + 2

        let lastLineOffset = timedLyrics.dropLast().map { $0.text }.joined(separator: "\n\n").count + (timedLyrics.count > 1 ? 2 : 0)
        let lastLineRange = layoutManager.glyphRange(
            forCharacterRange: NSRange(location: lastLineOffset, length: timedLyrics.last!.text.count),
            actualCharacterRange: nil
        )
        let lastLineRect = layoutManager.boundingRect(forGlyphRange: lastLineRange, in: textContainer)
        let lastLineY = lastLineRect.origin.y + lyricsTextView.textContainerInset.top
        let neededPadding = max(lyricsTextView.bounds.height - (lyricsTextView.contentSize.height - lastLineY), 0)

        lyricsTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: neededPadding, right: 0)
        lyricsTextView.scrollIndicatorInsets = lyricsTextView.contentInset

        lyricsTextView.layoutManager.ensureLayout(for: lyricsTextView.textContainer)

        let glyphRange = layoutManager.glyphRange(
            forCharacterRange: NSRange(location: charOffset, length: timedLyrics[index].text.count),
            actualCharacterRange: nil
        )
        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let finalY = boundingRect.origin.y + lyricsTextView.textContainerInset.top

        lyricsTextView.setContentOffset(CGPoint(x: 0, y: max(finalY, 0)), animated: true)
    }
}

// MARK: - LyricsDisplayDelegate
extension NowPlayingViewController: LyricsDisplayDelegate {
    func didSelectLyrics(trackName: String, artistName: String, syncedLyrics: String?, plainLyrics: String?, instrumental: Bool, albumArt: UIImage?) {
        songTitleLabel.text = trackName
        artistNameLabel.text = artistName
        if let image = albumArt { albumArtImageView.image = image }
        saveLastPlayedSong(trackName: trackName, artistName: artistName, service: .none)
        displayCleanLyrics(from: syncedLyrics, plainLyrics: plainLyrics, instrumental: instrumental)
    }
}

// MARK: - UITextViewDelegate (scroll detection)
extension NowPlayingViewController: UITextViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard isSpotifyActive else { return }
        userIsScrolling = true
        scrollReturnTimer?.invalidate()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard isSpotifyActive else { return }
        if !decelerate { startScrollReturnTimer() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isSpotifyActive else { return }
        startScrollReturnTimer()
    }

    private func startScrollReturnTimer() {
        scrollReturnTimer?.invalidate()
        scrollReturnTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.userIsScrolling = false
            if self.currentHighlightedIndex >= 0 {
                self.highlightAndScrollToLyric(at: self.currentHighlightedIndex)
            }
        }
    }
}
