//
//  SpotifyManager.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

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
    
    var onTrackChanged: ((String, String) -> Void)?
    var onConnectionStatusChanged: ((Bool) -> Void)?
    
    override init() {
        super.init()
        setupAppRemote()
    }
    
    private func setupAppRemote() {
        let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .none)
        appRemote?.delegate = self
    }
    
    func connect() {
        appRemote?.authorizeAndPlayURI("")
    }
    
    func disconnect() {
        appRemote?.disconnect()
    }
    
    func handleAuthCallback(url: URL) {
        let parameters = appRemote?.authorizationParameters(from: url)
        if let token = parameters?[SPTAppRemoteAccessTokenKey] as? String {
            UserDefaults.standard.set(token, forKey: tokenKey)
            appRemote?.connectionParameters.accessToken = token
            appRemote?.connect()
        }
    }
    
    func tryAutoConnect() {
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey) {
            appRemote?.connectionParameters.accessToken = savedToken
            appRemote?.connect()
        }
    }
}

// MARK: - SPTAppRemoteDelegate
extension SpotifyManager: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        onConnectionStatusChanged?(true)
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
            guard error == nil else { return }
            appRemote.playerAPI?.getPlayerState { result, _ in
                if let state = result as? SPTAppRemotePlayerState {
                    self.playerStateDidChange(state)
                }
            }
        })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        onConnectionStatusChanged?(false)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        onConnectionStatusChanged?(false)
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension SpotifyManager: SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        lastKnownPosition = Double(playerState.playbackPosition) / 1000.0
        lastKnownPositionTimestamp = Date()
        isPlaying = !playerState.isPaused
        
        let trackName = playerState.track.name
        let artistName = playerState.track.artist.name
        
        DispatchQueue.main.async {
            self.onTrackChanged?(trackName, artistName)
        }
    }
    
    func estimatedPlaybackPosition() -> Double {
        guard isPlaying else { return lastKnownPosition }
        return lastKnownPosition + Date().timeIntervalSince(lastKnownPositionTimestamp)
    }
    
    func pausePlayback() {
        guard let appRemote = appRemote, appRemote.isConnected else { return }
        appRemote.playerAPI?.pause(nil)
    }
    
    func isConnected() -> Bool {
        return appRemote?.isConnected ?? false
    }
}
