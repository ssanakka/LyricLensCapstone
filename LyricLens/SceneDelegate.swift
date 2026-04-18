//
//  SceneDelegate.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        let savedService = UserDefaults.standard.string(forKey: "activeMusicService") ?? "none"
        let autoDetectOn = UserDefaults.standard.bool(forKey: "autoDetectEnabled")

        if autoDetectOn && savedService == "spotify" {
            SpotifyManager.shared.onTrackChanged = { trackName, artistName in
                DispatchQueue.main.async {
                    self.updateNowPlayingForSpotify(trackName: trackName, artistName: artistName)
                }
            }

            SpotifyManager.shared.onConnectionStatusChanged = { connected in
                DispatchQueue.main.async {
                    self.handleSpotifyConnectionRestored(connected: connected)
                }
            }

            if let token = UserDefaults.standard.string(forKey: "spotify_access_token"), !token.isEmpty {
                SpotifyManager.shared.tryAutoConnect()
            }
        }
    }

    private func getNowPlayingVC() -> NowPlayingViewController? {
        guard let tabBar = window?.rootViewController as? UITabBarController,
              let nav = tabBar.viewControllers?.first as? UINavigationController,
              let vc = nav.viewControllers.first as? NowPlayingViewController else {
            return nil
        }
        return vc
    }

    private func handleSpotifyConnectionRestored(connected: Bool) {
        guard let nowPlayingVC = getNowPlayingVC() else { return }
        if connected {
            nowPlayingVC.setSpotifyMode(enabled: true)
            nowPlayingVC.setAppleMusicMode(enabled: false)
            nowPlayingVC.setAutoDetectEnabled(true)
        }
    }

    private func updateNowPlayingForSpotify(trackName: String, artistName: String) {
        guard let nowPlayingVC = getNowPlayingVC() else { return }
        nowPlayingVC.songTitleLabel.text = trackName
        nowPlayingVC.artistNameLabel.text = artistName
        nowPlayingVC.fetchLyricsForSpotifyTrack(trackName: trackName, artistName: artistName)
        nowPlayingVC.fetchAlbumArtForSpotifyTrack(trackName: trackName, artistName: artistName)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        SpotifyManager.shared.handleAuthCallback(url: url)
    }
}
