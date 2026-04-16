//
//  LRCLIBAPIService.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import Foundation

class LRCLIBAPIService {
    
    static let shared = LRCLIBAPIService()
    
    private let baseURL = "https://lrclib.net/api"
    
    // Fetch lyrics by exact track signature
    func fetchLyrics(trackName: String, artistName: String, albumName: String, duration: Int, completion: @escaping ([String: Any]?) -> Void) {
        
        // Create the URL with parameters
        let escapedTrackName = trackName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let escapedArtistName = artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let escapedAlbumName = albumName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(baseURL)/get?track_name=\(escapedTrackName)&artist_name=\(escapedArtistName)&album_name=\(escapedAlbumName)&duration=\(duration)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching lyrics: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                print("Lyrics not found (404)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                DispatchQueue.main.async {
                    completion(json)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    // Search for lyrics by keyword - returns array of dictionaries
    func searchLyrics(query: String, completion: @escaping ([[String: Any]]) -> Void) {
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search?q=\(escapedQuery)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid search URL")
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Search error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                DispatchQueue.main.async {
                    completion(jsonArray)
                }
            } catch {
                print("Search parse error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}
