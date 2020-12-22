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
    var presents: String = ""
    
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
            by = "by"
            presents = "Presents"
           } catch {
                print("Contents could not be loaded")
                artist = "Could not load artist info"
                song = "Could not load song info"
                by = ""
                presents = ""
           }
       } else {
            print("URL was bad!")
            artist = ""
            song = ""
            by = "Stream link is down"
       }
    }
    
        func djUpdater() {
    
            struct Response: Codable { // or Decodable
              let currentDJ: String
            }
    
            if let url = URL(string: "https://us-central1-wvum-d6fb8.cloudfunctions.net/getDJ") {
               URLSession.shared.dataTask(with: url) { data, response, error in
                  if let data = data {
                      do {
                        let res = try JSONDecoder().decode(Response.self, from: data)
                        print(res.currentDJ)
                        if res.currentDJ == "Rotation" {
                            self.dj = "WVUM"
                        }
                        else {
                            self.dj = res.currentDJ
                        }
                      } catch {
                         print(error)
                        self.dj = "WVUM"
                      }
                   }
               }.resume()
            }
        }
    
    
}
