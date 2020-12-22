//
//  RadioPlayer.swift
//  Radio Demo (Swift)
//
//  Created by Samuel Garry on 6/1/20.
//  Copyright © 2020 Sam Garry. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer

class RadioPlayer: NSObject {
    //VARIABLES
    var player:AVPlayer?
//    let playerItem = AVPlayerItem(url: NSURL(string: "http://s7.voscast.com:8692/stream")! as URL)
    let playerItem = AVPlayerItem(url: NSURL(string: "http://s7.voscast.com:8692/stream")! as URL)
    let session = AVAudioSession.sharedInstance()
    

    // FUNCTIONS
    func initAVSession() {
        do {
            // Configure audio session category, options, and mode
            try session.setCategory(AVAudioSession.Category.playback)
            // Activate audio session to enable your custom configuration
            try session.setActive(true)
        } catch {
            print("Unable to activate audio session:  \(error.localizedDescription)")
        }
    }
    
    func play() {
        let newPlayerItem = AVPlayerItem(asset:playerItem.asset)
        player = AVPlayer(playerItem: newPlayerItem)
        player!.play()
    }
    
    func pause() {
        player = nil
    }
}
