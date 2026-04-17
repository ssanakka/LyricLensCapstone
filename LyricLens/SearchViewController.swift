//
//  SearchViewController.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var songTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var searchResults: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        
        //dismiss keyboard when tapping outside
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //view.addGestureRecognizer(tapGesture)
        
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
    }
    //@objc func dismissKeyboard() {
      //  view.endEditing(true)
    //}
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        // Block search if auto-detect is on
        let autoDetectOn = UserDefaults.standard.bool(forKey: "autoDetectEnabled")
        if autoDetectOn {
            let alert = UIAlertController(
                title: "Auto-Detect is On",
                message: "Please turn off auto-detect in Settings before searching manually.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
                self.tabBarController?.selectedIndex = 2
            })
            present(alert, animated: true)
            return
        }
        
        guard let artist = artistTextField.text, !artist.isEmpty,
              let song = songTextField.text, !song.isEmpty else {
            let alert = UIAlertController(title: "Missing Info", message: "Please enter both artist name and song title", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        searchButton.isEnabled = false
        searchButton.setTitle("Searching...", for: .disabled)
        
        let searchQuery = "\(artist) \(song)"
        
        LRCLIBAPIService.shared.searchLyrics(query: searchQuery) { [weak self] results in
            guard let self = self else { return }
            
            self.searchButton.isEnabled = true
            self.searchButton.setTitle("Search", for: .normal)
            self.searchResults = results
            self.resultsTableView.reloadData()
            
            if results.isEmpty {
                let alert = UIAlertController(title: "No Results", message: "No lyrics found for '\(searchQuery)'", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    // Dismiss keyboard when user starts scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        let result = searchResults[indexPath.row]
        let trackName = result["trackName"] as? String ?? "Unknown Track"
        let artistName = result["artistName"] as? String ?? "Unknown Artist"
        cell.textLabel?.text = "\(trackName) - \(artistName)"
        return cell
    }
    
    func fetchAlbumArt(trackName: String, artistName: String, completion: @escaping (UIImage?) -> Void) {
        let searchQuery = "\(trackName) \(artistName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(searchQuery)&limit=1&entity=song"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let artworkURLString = firstResult["artworkUrl100"] as? String,
                   let artworkURL = URL(string: artworkURLString) {
                    
                    // Fetch the actual image
                    URLSession.shared.dataTask(with: artworkURL) { imageData, _, _ in
                        if let imageData = imageData, let image = UIImage(data: imageData) {
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    }.resume()
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedResult = searchResults[indexPath.row]
        
        // Pass to Now Playing screen
        if let tabBarController = tabBarController,
           let viewControllers = tabBarController.viewControllers,
           let navController = viewControllers[0] as? UINavigationController,
           let nowPlayingVC = navController.viewControllers.first as? NowPlayingViewController {
            
            // Create a Lyrics-like object from the dictionary
            let trackName = selectedResult["trackName"] as? String
            let artistName = selectedResult["artistName"] as? String
            let instrumental = selectedResult["instrumental"] as? Bool ?? false
            let syncedLyrics = selectedResult["syncedLyrics"] as? String
            let plainLyrics = selectedResult["plainLyrics"] as? String
            
            nowPlayingVC.displayLyricsFromDict(
                trackName: trackName,
                artistName: artistName,
                instrumental: instrumental,
                syncedLyrics: syncedLyrics,
                plainLyrics: plainLyrics
            )
            
            if let track = trackName {
                nowPlayingVC.songTitleLabel.text = track
            }
            if let artist = artistName {
                nowPlayingVC.artistNameLabel.text = artist
            }
            
            if let track = trackName, let artist = artistName {
                fetchAlbumArt(trackName: track, artistName: artist) { image in
                    DispatchQueue.main.async {
                        if let albumArt = image {
                            nowPlayingVC.albumArtImageView.image = albumArt
                        }
                    }
                }
            }
        }
        
        tabBarController?.selectedIndex = 0
    }
}
