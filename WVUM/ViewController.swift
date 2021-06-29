//
//  ViewController.swift
//  WVUM
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
    @IBOutlet var withLabel: UILabel!
    @IBOutlet var byLabel: UILabel!
    @IBOutlet var background: UIImageView!
    @IBOutlet var leftLogo: UIImageView!
    
    let streamer = RadioPlayer()
    let reader = DataReader()
    var timer = Timer()
    var djTimer = Timer()
    let infoCC = MPNowPlayingInfoCenter.default()
    
    //play and pause symbol configurations
    let playConfig = UIImage.SymbolConfiguration(pointSize: 75, weight: .bold, scale: .large)
    let pauseConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold, scale: .large)
    
    //Album artwork initialization
    let albumImage = UIImage(named: "albumArtwork")!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamer.initAVSession()
        scheduledTimerWithTimeInterval()
        reader.metadataUpdater()
        reader.djUpdater()
        updateGeneralMetadata()
        setupRemoteTransportControls()
        
        //Set up initial meta data label assignments
        initMetaDataLabels()

        //Set up background image
        background.image = UIImage(named: "background.png")
        background.contentMode = .scaleAspectFill
        background.backgroundColor = .black
        background.alpha = 0.75
        
        //Set up play/pause button image
        btnPlay.setImage(UIImage(systemName: "play.fill", withConfiguration: playConfig), for: UIControl.State.normal)
        btnPlay.tintColor = .white
        
        //Shadow (not using this for this version)
//        btnPlay.layer.shadowColor = UIColor.gray.cgColor
//        btnPlay.layer.shadowOffset = CGSize(width: 5, height: 5)
//        btnPlay.layer.shadowRadius = 4
//        btnPlay.layer.shadowOpacity = 1.0
        
        //Set up logo images
        leftLogo.image = UIImage(named: "logoWVUM.png") //Left Image
        leftLogo.alpha = 0.9
    }
    
    //Set up meta data label assignments
    func initMetaDataLabels() {
        songLabel.text = reader.song
        byLabel.text = reader.by
        artistLabel.text = reader.artist
        withLabel.text = reader.with
        djLabel.text = reader.dj
        print("djLabel: " + reader.dj)
    }
    
    //Make the elements of the status bar dark
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
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
        reader.metadataUpdater()
        buttonUpdater() //update control panel and notification center every second
        
        initMetaDataLabels()
    }
    
    @objc func djTimerFired() {
        reader.djUpdater() //This gets called every five minutes
    }
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        djTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.djTimerFired), userInfo: nil, repeats: true)
    }
        
    func updateGeneralMetadata() {
        /*guard player.url != nil, let _ = player.url else {
            infoCC.nowPlayingInfo = nil
            return
        }*/
        var nowPlayingInfo = infoCC.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = reader.song
        nowPlayingInfo[MPMediaItemPropertyArtist] = reader.artist
        let albumArt = MPMediaItemArtwork.init(boundsSize: albumImage.size,
                requestHandler: { (size) -> UIImage in return self.albumImage })
        nowPlayingInfo[MPMediaItemPropertyArtwork] = albumArt
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

