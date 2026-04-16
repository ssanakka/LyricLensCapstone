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
        
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResultCell")
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
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
        }
        
        tabBarController?.selectedIndex = 0
    }
}
