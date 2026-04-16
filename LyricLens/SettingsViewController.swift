//
//  SettingsViewController.swift
//  LyricLens
//
//  Created by Sumanth Sanakkayala on 4/13/26.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var autoDetectSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
    
    @IBAction func autoDetectToggled(_ sender: UISwitch) {
        let status = sender.isOn ? "ON" : "OFF"
        print("Auto-detect music: \(status)")
        
        let alert = UIAlertController(title: "Auto-Detect", message: "Music detection is now \(status).\n\nNote: Full auto-detection will be implemented with MusicKit integration in the next version.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func spotifyButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Spotify Connect", message: "Spotify integration will be available in a future update!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
