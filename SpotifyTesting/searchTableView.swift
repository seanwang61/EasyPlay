//
//  searchTableView.swift
//  SpotifyTesting
//
//  Created by Sean Wang on 10/30/15.
//  Copyright © 2015 cse190. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class searchTableView: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    @IBOutlet weak var SearchBar: UITextField!
    
    
    @IBAction func searchSongs(sender: AnyObject) {
        print("searchDisplayController called")
        self.getSongs(SearchBar.text);
        
    }
    
    var songs: [Song] = []

    
    func getSongs(timer: String!) {
        
        print("getSongs called")
        let searchTerm = timer
        
        self.title = "Results for \(searchTerm)"
        
        // logic to switch service; need to eventually move this to an interface
        // or move this code inside a rest API, and then into an interface
        
        // URL encode the search term
        let searchTermEncoded = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        // create the url for the web request
        let uri: String = "https://api.spotify.com/v1/search?q=\(searchTermEncoded!)&type=artist,album,track"
        
        
        Alamofire
            .request(.GET, uri)
            .response { request, response, data, error in
                
                let json = JSON(data: data!)
                
                print(json["tracks"]["items"].count);
                print(json["tracks"]["items"])
                
                for var i = 0; i < json["tracks"]["items"].count; i++ {
                    
                    let data = json["tracks"]["items"][i]
                    
                    // return the object list
                    let song = Song()
                    
                    song.title = data["name"].string!
                    song.album = data["album"]["name"].string!
                    song.artist = data["artists"][0]["name"].string!
                    song.trackID = data["id"].string!
                    
                    
                    self.songs += [song]
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView!.reloadData()
                }
        }
        // call to Spotify API
        /*
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=loveland&type=track").response { request, response, data, error in
        
        let json = JSON(data: data!)
        
        print(json["tracks"]["items"].count);
        //print(json["tracks"]["items"])
        
        for var i = 0; i < json["tracks"]["items"].count; i++ {
        
        let data = json["tracks"]["items"][i]
        
        // return the object list
        let song = Song()
        
        song.title = data["name"].string!
        song.album = data["album"]["name"].string!
        song.artist = data["artists"][0]["name"].string!
        song.trackID = data["id"].string!
        
        print(song.title)
        print(song.artist)
        print(song.trackID)
        
        self.songs += [song]
        
        }
        
        
        dispatch_async(dispatch_get_main_queue()) {
        self.tableView!.reloadData()
        }
        }*/
        
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        
        print("searchDisplayController called")
        self.getSongs(searchString)
        
        return true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let song = songs[indexPath.row]
        
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.artist + " - " + song.album
        
        return cell
    }

}
