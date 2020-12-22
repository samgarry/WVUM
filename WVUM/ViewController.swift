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
    @IBOutlet var djLabel: UILabel!
    @IBOutlet var presentsLabel: UILabel!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var background: UIImageView!
    
    let streamer = RadioPlayer()
    let reader = DataReader()
    var timer = Timer()
    let infoCC = MPNowPlayingInfoCenter.default()
    let playConfig = UIImage.SymbolConfiguration(pointSize: 75, weight: .bold, scale: .large)
    let pauseConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold, scale: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamer.initAVSession()
        scheduledTimerWithTimeInterval()
        reader.metadataUpdater()
        reader.djUpdater()
        updateGeneralMetadata()
        setupRemoteTransportControls()
        
        //Set up images
        background.image = UIImage(named: "background.png")
        background.contentMode = .scaleAspectFill
        background.backgroundColor = .black
        background.alpha = 0.8
        btnPlay.setImage(UIImage(systemName: "play.fill", withConfiguration: playConfig), for: UIControl.State.normal)
        btnPlay.tintColor = .white
        btnPlay.layer.shadowColor = UIColor.gray.cgColor
        btnPlay.layer.shadowOffset = CGSize(width: 5, height: 5)
        btnPlay.layer.shadowRadius = 4
        btnPlay.layer.shadowOpacity = 1.0      }

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
        reader.metadataUpdater()
        reader.djUpdater()
        buttonUpdater()
        
        //Set meta data labels to the variables from the Data Reader
        artistLabel.text = reader.artist
        songLabel.text = reader.song
        djLabel.text = reader.dj
        fromLabel.text = reader.by
        presentsLabel.text = reader.presents
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
        nowPlayingInfo[MPMediaItemPropertyTitle] = reader.song
        nowPlayingInfo[MPMediaItemPropertyArtist] = reader.artist
        //nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item?.albumTitle
        //nowPlayingInfo[MPMediaItemPropertyArtwork] = item?.artwork
        infoCC.nowPlayingInfo = nowPlayingInfo
    }
    
    func buttonUpdater() {
        if ((streamer.player?.rate == 1.0) && (streamer.player?.error == nil)) {
            btnPlay.setImage(UIImage(systemName: "pause.fill", withConfiguration: pauseConfig), for: UIControl.State.normal)        }
        else {
            btnPlay.setImage(UIImage(systemName: "play.fill", withConfiguration: playConfig), for: UIControl.State.normal)
            streamer.pause()
        }
        btnPlay.tintColor = .white
    }
    
    @IBAction func btnPress(sender: AnyObject) {
        if streamer.player != nil {
            streamer.pause()
            btnPlay.setImage(UIImage(systemName: "play.fill", withConfiguration: playConfig), for: UIControl.State.normal)
        }
        else {
            streamer.play()
            btnPlay.setImage(UIImage(systemName: "pause.fill", withConfiguration: pauseConfig), for: UIControl.State.normal)
        }
    }
}

