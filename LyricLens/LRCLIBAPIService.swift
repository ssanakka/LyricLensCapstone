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
    
    func searchLyrics(query: String, completion: @escaping ([Lyrics]) -> Void) {
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search?q=\(escapedQuery)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            do {
                let results = try JSONDecoder().decode([Lyrics].self, from: data)
                DispatchQueue.main.async { completion(results) }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
}
