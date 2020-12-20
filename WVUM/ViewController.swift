//
//  ViewController.swift
//  Radio Demo (Swift)
//
//  Created by Samuel Garry on 5/23/20.
//  Copyright © 2020 Sam Garry. All rights reserved.
//


// FIGURE OUT WHAT TO DO INSTEAD OF ALLOWING ARBITRARY LOADS
// LOOK INTO ADDING THE SYNC() FUNCTION THING TO THE METADATAUPDATER()
// ADDING THE GUARD TO UPDATEGENERALMETADATA()


import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var songLabel: UILabel!
    
    let streamer = RadioPlayer()
    var timer = Timer()
    let infoCC = MPNowPlayingInfoCenter.default()
    var artist: String = ""
    var song: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamer.initAVSession()
        scheduledTimerWithTimeInterval()
        metadataUpdater()
        updateGeneralMetadata()
        setupRemoteTransportControls()
        btnPlay.setImage(UIImage(named: "playButton.png"), for: UIControl.State.normal)
        
        struct Response: Codable { // or Decodable
          let currentDJ: String
        }
        
        // REFRESH DJ EVERY FIVE MINUTES
        
        if let url = URL(string: "https://us-central1-wvum-d6fb8.cloudfunctions.net/getDJ") {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  do {
                     let res = try JSONDecoder().decode(Response.self, from: data)
                     print(res.currentDJ)
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
        }
    }
    
    
    

    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.streamer.player?.rate == nil || self.streamer.player?.rate == 0.0 {
                self.streamer.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.streamer.player?.rate == 1.0 {
                self.streamer.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    @objc func timerFired() {
        updateGeneralMetadata()
        metadataUpdater()
        statusUpdater()
    }
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
    }
    
    func updateGeneralMetadata() {
        /*guard player.url != nil, let _ = player.url else {
            infoCC.nowPlayingInfo = nil
            return
        }*/
        //let item = currentItem
        var nowPlayingInfo = infoCC.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        //nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item?.albumTitle
        //nowPlayingInfo[MPMediaItemPropertyArtwork] = item?.artwork
        infoCC.nowPlayingInfo = nowPlayingInfo
    }
    
    func statusUpdater() {
        if ((streamer.player?.rate == 1.0) && (streamer.player?.error == nil)) {
            self.btnPlay.setImage(UIImage(named: "pauseButton.png"), for: UIControl.State.normal)
        }
        else {
            self.btnPlay.setImage(UIImage(named: "playButton.png"), for: UIControl.State.normal)
            streamer.pause()
        }
    }
           
    func metadataUpdater() {
        if let trackURL = URL(string: "http://cdn.voscast.com/stats/display.js?key=35d25babae2f8cb7af0a4f9f0d7f9821&stats=songtitle&bid=5ed2929d959c0&action=update") {
           do {
            let delimiter = "\""
            let contents = try String(contentsOf: trackURL)
            let data = contents.components(separatedBy: delimiter)
            let songInfoSegment = "\(data[3])"
            
            let delimiter2 = "-"
            let songInfo = songInfoSegment.components(separatedBy: delimiter2)
            artist = "\(songInfo[0])"
            song = "\(songInfo[1])"
                
                
                
            artistLabel.text = artist
            songLabel.text = song
            
           } catch {
               print("Contents could not be loaded")
           }
       } else {
           print("URL was bad!")
       }
    }
    
    @IBAction func btnPress(sender: AnyObject) {
        if streamer.player != nil {
            streamer.pause()
            btnPlay.setImage(UIImage(named: "playButton.png"), for: UIControl.State.normal)
        }
        else {
            streamer.play()
            btnPlay.setImage(UIImage(named: "pauseButton.png"), for: UIControl.State.normal)
            
        }
    }
}

