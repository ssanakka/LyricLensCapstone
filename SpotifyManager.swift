//
//  SpotifyManager.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit
import SpotifyiOS

class SpotifyManager: NSObject {
    
    private(set) var lastKnownPosition: Double = 0
    private(set) var lastKnownPositionTimestamp: Date = Date()
    private(set) var isPlaying: Bool = false
    
    static let shared = SpotifyManager()
    
    private let clientID = "81e124d625104bbcbbae43377ceb0435"
    private let redirectURI = URL(string: "lyriclens://callback")!
    private let tokenKey = "spotify_access_token"
    
    private var appRemote: SPTAppRemote?
    private var accessToken: String?
    
    var onTrackChanged: ((String, String) -> Void)?
    var onConnectionStatusChanged: ((Bool) -> Void)?
    
    override init() {
        super.init()
        setupAppRemote()
    }
    
    private func setupAppRemote() {
        let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        configuration.playURI = ""
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote?.delegate = self
    }
    
    func connect() {
        print("🟢 Connecting to Spotify...")
        appRemote?.authorizeAndPlayURI("")
    }
    
    func disconnect() {
        appRemote?.disconnect()
    }
    
    func handleAuthCallback(url: URL) {
        print("🟢 Callback received: \(url)")
        let parameters = appRemote?.authorizationParameters(from: url)
        
        if let token = parameters?[SPTAppRemoteAccessTokenKey] as? String {
            print("🟢 Got token, saving...")
            accessToken = token
            UserDefaults.standard.set(token, forKey: tokenKey)
            appRemote?.connectionParameters.accessToken = token
            appRemote?.connect()
        } else {
            print("❌ No token in callback")
        }
    }
    
    func tryAutoConnect() {
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey) {
            print("🟢 Saved token found, attempting reconnect...")
            accessToken = savedToken
            appRemote?.connectionParameters.accessToken = savedToken
            appRemote?.connect()
        } else {
            print("No saved token")
        }
    }
}

// MARK: - SPTAppRemoteDelegate
extension SpotifyManager: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("✅✅✅ SPOTIFY CONNECTED! ✅✅✅")
        print("🎯 Calling onConnectionStatusChanged with true")
        onConnectionStatusChanged?(true)
        
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
            if let error = error {
                print("Subscribe error: \(error)")
            } else {
                print("✅ Subscribed to player state")
                appRemote.playerAPI?.getPlayerState { result, error in
                    if let state = result as? SPTAppRemotePlayerState {
                        self.playerStateDidChange(state)
                    }
                }
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("❌ Connection failed: \(error?.localizedDescription ?? "unknown")")
        onConnectionStatusChanged?(false)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("❌ Disconnected from Spotify")
        onConnectionStatusChanged?(false)
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension SpotifyManager: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        let trackName = playerState.track.name
        let artistName = playerState.track.artist.name
        
        lastKnownPosition = Double(playerState.playbackPosition) / 1000.0
        lastKnownPositionTimestamp = Date()
        isPlaying = !playerState.isPaused
        
        print("🎵🎵🎵 SONG CHANGED: \(trackName) by \(artistName) 🎵🎵🎵")
        
        DispatchQueue.main.async {
            self.onTrackChanged?(trackName, artistName)
        }
    }
    func estimatedPlaybackPosition() -> Double {
        guard isPlaying else { return lastKnownPosition }
        let elapsed = Date().timeIntervalSince(lastKnownPositionTimestamp)
        return lastKnownPosition + elapsed
    }
    
    func getAppRemote() -> SPTAppRemote? {
        return appRemote
    }
    private func stopSpotifyPlayback() {
        SpotifyManager.shared.pausePlayback()
    }
    
    func pausePlayback() {
        guard let appRemote = appRemote, appRemote.isConnected else {
            print("❌ Cannot pause - Spotify not connected")
            return
        }
        appRemote.playerAPI?.pause { result, error in
            if let error = error {
                print("❌ Failed to pause: \(error.localizedDescription)")
            } else {
                print("⏸️ Spotify playback paused")
            }
        }
    }

    func isSpotifyPlaying() -> Bool {
        // This will be checked via player state
        return false // We'll track this separately if needed
    }
    
    func isConnected() -> Bool {
        return appRemote?.isConnected ?? false
    }
}
