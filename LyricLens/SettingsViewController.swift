//
//  SettingsViewController.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let activeServiceKey = "activeMusicService"
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var appleMusicButton: UIButton!
    @IBOutlet weak var stopAutoDetectButton: UIButton!
    
    private var isSpotifyConnected = false
    private var isAppleMusicConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"

        // Style buttons
        spotifyButton.setTitleColor(.systemGreen, for: .normal)
        appleMusicButton.setTitleColor(UIColor(red: 1.0, green: 0.0157, blue: 0.2118, alpha: 1.0), for: .normal)
        stopAutoDetectButton.setTitleColor(.systemRed, for: .normal)

        let savedService = UserDefaults.standard.string(forKey: "activeMusicService") ?? "none"
        let autoDetectOn = UserDefaults.standard.bool(forKey: "autoDetectEnabled")

        // Set UI immediately based on saved state — no flash
        if !autoDetectOn || savedService == "none" {
            isAppleMusicConnected = false
            isSpotifyConnected = false
            appleMusicButton.setTitle("Connect to Apple Music", for: .normal)
            appleMusicButton.isEnabled = true
            spotifyButton.setTitle("Connect to Spotify", for: .normal)
            spotifyButton.isEnabled = true
        } else if savedService == "spotify" {
            isSpotifyConnected = true
            isAppleMusicConnected = false
            spotifyButton.setTitle("Connected to Spotify", for: .normal)
            spotifyButton.setTitleColor(.systemGreen, for: .normal)
            spotifyButton.isEnabled = false
            appleMusicButton.setTitle("Connect to Apple Music", for: .normal)
            appleMusicButton.setTitleColor(UIColor(red: 1.0, green: 0.0157, blue: 0.2118, alpha: 1.0), for: .normal)
            appleMusicButton.isEnabled = true
        } else if savedService == "appleMusic" {
            isAppleMusicConnected = true
            isSpotifyConnected = false
            appleMusicButton.setTitle("Connected to Apple Music", for: .normal)
            appleMusicButton.setTitleColor(.systemGreen, for: .normal)
            appleMusicButton.isEnabled = false
            spotifyButton.setTitle("Connect to Spotify", for: .normal)
            spotifyButton.isEnabled = true
        }

        // Wire up Spotify callbacks
        SpotifyManager.shared.onConnectionStatusChanged = { [weak self] connected in
            DispatchQueue.main.async {
                if connected {
                    self?.handleSpotifyConnected()
                } else {
                    self?.handleSpotifyDisconnected()
                }
            }
        }

        SpotifyManager.shared.onTrackChanged = { [weak self] trackName, artistName in
            DispatchQueue.main.async {
                self?.updateNowPlayingScreen(trackName: trackName, artistName: artistName)
            }
        }

    }
    
    private func restoreConnectionState() {
        // Check if Spotify is connected
        if SpotifyManager.shared.isConnected() {
            handleSpotifyConnected()
        } else if UserDefaults.standard.bool(forKey: "autoDetectEnabled") {
            // Auto-detect is on, check which service was active
            if isAppleMusicConnected {
                // Apple Music was active
                enableAppleMusicOnly()
            }
        }
    }
    
    private func handleSpotifyConnected() {
        isSpotifyConnected = true
        isAppleMusicConnected = false
        UserDefaults.standard.set("spotify", forKey: activeServiceKey)
        spotifyButton.setTitle("Connected to Spotify", for: .normal)
        spotifyButton.setTitleColor(.systemGreen, for: .normal)
        spotifyButton.isEnabled = false
        appleMusicButton.setTitle("Connect to Apple Music", for: .normal)
        appleMusicButton.setTitleColor(UIColor(red: 1.0, green: 0.0157, blue: 0.2118, alpha: 1.0), for: .normal)
        appleMusicButton.isEnabled = true
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setSpotifyMode(enabled: true)
            nowPlayingVC.setAppleMusicMode(enabled: false)
            nowPlayingVC.setAutoDetectEnabled(true)
        }
        
        print("✅ Spotify active")
    }
    
    private func handleSpotifyDisconnected() {
        isSpotifyConnected = false
        spotifyButton.setTitle("Connect to Spotify", for: .normal)
        spotifyButton.setTitleColor(.systemGreen, for: .normal)
        spotifyButton.isEnabled = true
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setSpotifyMode(enabled: false)
        }
    }
    
    private func disconnectAppleMusic() {
        isAppleMusicConnected = false
        appleMusicButton.setTitle("Connect to Apple Music", for: .normal)
        appleMusicButton.setTitleColor(UIColor(red: 1.0, green: 0.0157, blue: 0.2118, alpha: 1.0), for: .normal)
        appleMusicButton.isEnabled = true
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setAppleMusicMode(enabled: false)
        }
        
        print("Apple Music disconnected")
    }
    
    private func disconnectSpotify() {
        isSpotifyConnected = false
        SpotifyManager.shared.disconnect()
        spotifyButton.setTitle("Connect to Spotify", for: .normal)
        spotifyButton.setTitleColor(.systemGreen, for: .normal)
        spotifyButton.isEnabled = true
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setSpotifyMode(enabled: false)
        }
        
        print("Spotify disconnected")
    }
    
    private func getNowPlayingViewController() -> NowPlayingViewController? {
        if let tabBarController = tabBarController,
           let navController = tabBarController.viewControllers?[0] as? UINavigationController,
           let nowPlayingVC = navController.viewControllers.first as? NowPlayingViewController {
            return nowPlayingVC
        }
        return nil
    }
    
    private func updateNowPlayingScreen(trackName: String, artistName: String) {
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.songTitleLabel.text = trackName
            nowPlayingVC.artistNameLabel.text = artistName
            nowPlayingVC.fetchLyricsForSpotifyTrack(trackName: trackName, artistName: artistName)
            nowPlayingVC.fetchAlbumArtForSpotifyTrack(trackName: trackName, artistName: artistName)
        }
    }
    
    // MARK: - Stop Auto Detect Button
    
    @IBAction func stopAutoDetectTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Stop Auto-Detect?",
            message: "Auto-detect will be disabled. You'll need to use the Search tab to find lyrics manually.\n\nThis will disconnect both Apple Music and Spotify.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive) { _ in
            self.disableAllServices()
        })
        present(alert, animated: true)
    }
    
    private func disableAllServices() {
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.lyricsTextView.text = "Auto-detect is OFF.\n\nUse the Search tab to find lyrics manually."
        }
        
        if isSpotifyConnected {
            disconnectSpotify()
        }
        
        if isAppleMusicConnected {
            disconnectAppleMusic()
        }
        
        UserDefaults.standard.set(false, forKey: "autoDetectEnabled")
        UserDefaults.standard.set("none", forKey: activeServiceKey)
        
        isAppleMusicConnected = false
        isSpotifyConnected = false
        
        appleMusicButton.setTitle("Connect to Apple Music", for: .normal)
        appleMusicButton.setTitleColor(UIColor(red: 1.0, green: 0.0157, blue: 0.2118, alpha: 1.0), for: .normal)
        appleMusicButton.isEnabled = true
        spotifyButton.setTitle("Connect to Spotify", for: .normal)
        spotifyButton.setTitleColor(.systemGreen, for: .normal)
        spotifyButton.isEnabled = true
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setAppleMusicMode(enabled: false)
            nowPlayingVC.setSpotifyMode(enabled: false)
            nowPlayingVC.setAutoDetectEnabled(false)
            nowPlayingVC.lyricsTextView.text = "Auto-detect is OFF.\n\nUse the Search tab to find lyrics manually."
        }
        
        print("All services disabled")
    }
    
    // MARK: - Apple Music
    
    private func enableAppleMusicOnly() {
        if isSpotifyConnected {
            disconnectSpotify()
        }
        
        isAppleMusicConnected = true
        UserDefaults.standard.set("appleMusic", forKey: activeServiceKey)  // ADD THIS LINE
        UserDefaults.standard.set(true, forKey: "autoDetectEnabled")
        
        appleMusicButton.setTitle("Connected to Apple Music", for: .normal)
        appleMusicButton.setTitleColor(.systemGreen, for: .normal)
        appleMusicButton.isEnabled = false
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setAppleMusicMode(enabled: true)
            nowPlayingVC.setAutoDetectEnabled(true)
            nowPlayingVC.setSpotifyMode(enabled: false)
        }
        
        print("Apple Music activated")
    }
    
    private func enableAppleMusic() {
        enableAppleMusicOnly()
    }
    
    // MARK: - Spotify
    
    @IBAction func spotifyButtonTapped(_ sender: UIButton) {
        if isAppleMusicConnected {
            let alert = UIAlertController(
                title: "Switch to Spotify?",
                message: "Connecting to Spotify will disconnect you from Apple Music. Continue?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Switch", style: .default) { _ in
                self.disableAppleMusic()
                self.connectToSpotify()
            })
            present(alert, animated: true)
        } else {
            connectToSpotify()
        }
    }
    
    private func disableAppleMusic() {
        isAppleMusicConnected = false
        appleMusicButton.setTitle("Connect to Apple Music", for: .normal)
        appleMusicButton.setTitleColor(UIColor(red: 1.0, green: 0.0157, blue: 0.2118, alpha: 1.0), for: .normal)
        appleMusicButton.isEnabled = true
        
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.setAppleMusicMode(enabled: false)
        }
    }
    
    private func connectToSpotify() {
        // Enable auto-detect
        UserDefaults.standard.set(true, forKey: "autoDetectEnabled")
        
        print("🟢 Connect button tapped")
        spotifyButton.setTitle("Connecting...", for: .normal)
        spotifyButton.setTitleColor(.systemGray, for: .normal)
        spotifyButton.isEnabled = false
        SpotifyManager.shared.connect()
    }
    
    // MARK: - Apple Music Button
    
    @IBAction func appleMusicButtonTapped(_ sender: UIButton) {
        if isSpotifyConnected {
            let alert = UIAlertController(
                title: "Switch to Apple Music?",
                message: "Connecting to Apple Music will disconnect Spotify and stop Spotify playback. Continue?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Switch", style: .default) { _ in
                self.switchToAppleMusic()
            })
            present(alert, animated: true)
        } else {
            switchToAppleMusic()
        }
    }

    private func switchToAppleMusic() {
        // Clear album art
        if let nowPlayingVC = getNowPlayingViewController() {
            nowPlayingVC.clearAlbumArt()
        }
        
        // 1. Pause Spotify playback first
        SpotifyManager.shared.pausePlayback()
        
        // 2. Small delay to let pause happen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 3. Disconnect Spotify
            self.disconnectSpotify()
            
            // 4. Enable Apple Music
            self.enableAppleMusicOnly()
            
            print("✅ Switched to Apple Music, Spotify paused and disconnected")
        }
    }
}
