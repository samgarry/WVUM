//
//  DataReader.swift
//  WVUM
//
//  Created by Samuel Garry on 12/20/20.
//  Copyright © 2020 Sam Garry. All rights reserved.
//

import Foundation

class DataReader : NSObject {
    var artist: String = ""
    var song: String = ""
    var dj: String = ""
    var by: String = ""
    var with: String = ""
    
    func metadataUpdater() {
        if let trackURL = URL(string: "http://cdn.voscast.com/stats/display.js?key=35d25babae2f8cb7af0a4f9f0d7f9821&stats=songtitle&bid=5ed2929d959c0&action=update") {
           do {
            let delimiter = "\""
            let contents = try String(contentsOf: trackURL)
            let data = contents.components(separatedBy: delimiter)
            let songInfoSegment = "\(data[3])"
            
            let delimiter2 = "-"
            let songInfo = songInfoSegment.components(separatedBy: delimiter2)
            song = "\(songInfo[0])"
            artist = "\(songInfo[1])"
            by = "by"
            with = "with"
           } catch {
                print("Contents could not be loaded")
                artist = "Could not load artist info"
                song = "Could not load song info"
                by = ""
                with = ""
           }
       } else {
            print("URL was bad!")
            artist = ""
            song = ""
            by = "Stream link is down"
       }
    }
    
    func djUpdater() {
        if let djURL = URL(string: "https://us-central1-wvum-d6fb8.cloudfunctions.net/getDJ") {
           do {
            let delimiter = "\""
            let contents = try String(contentsOf: djURL)
            let data = contents.components(separatedBy: delimiter)
            dj = "\(data[3])"
            if dj == "Rotation" {
                dj = "WVUM"
            }
            with = "with"
           } catch {
                with = ""
                dj = "Could not load dj info"
           }
       } else {
            with = ""
            dj = "Dj metadata link is down"
            print("dj URL was bad!")
       }
    }
}
