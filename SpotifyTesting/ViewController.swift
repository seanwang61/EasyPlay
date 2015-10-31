//
//  ViewController.swift
//  SpotifyTesting
//
//  Created by Sean Wang on 10/22/15.
//  Copyright © 2015 cse190. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class ViewController: UIViewController {

    //"https://api.spotify.com/v1/search?q=tania%20bowra&type=artist"
    
    let kClientID = "4d63faabbbed404384264f330f8610b7";
    let kCallBackURL = "SpotifyTesting://callback"

    var session:SPTSession!
    var player:SPTAudioStreamingController?

    
    var userPlaylistTrackStrings = [NSURL]()
    var isPlaying = false;
    
    
    //table view
    @IBOutlet
    var tableView: UITableView!
    
    //var timer: NSTimer = NSTimer()

    
    
    //array of songs returned by spotify search request
    var songs: [Song] = []
    
    @IBOutlet weak var PlayPause: UIButton!
    
    @IBOutlet weak var Next: UIButton!
    
    @IBAction func PlayPause(sender: AnyObject) {
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        self.player?.setIsPlaying(isPlaying, callback: nil)
        
        if(isPlaying == false){
            isPlaying = true;
            print("music paused")
        }
        else
        {
            print("music played")
            isPlaying = false;
        }
        //self.player?.setIsPlaying(isPlaying, callback: nil)
        /*
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=loveland&type=track")
            .responseJSON { response in
                debugPrint(response)*/
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
        }
        
        
    }
    @IBAction func SkipForwardSong(sender: AnyObject) {
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        player?.skipNext(nil)
    }
    
    func addSongtoPlaylist(trackID: String)
    {
        print("song added to playlist!")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
        }
        
        var formattedTrackName = NSURL(string: "spotify:track:"+trackID);
        print(formattedTrackName)
        userPlaylistTrackStrings.append(formattedTrackName!)
        //self.player?.queueURI(<#T##uri: NSURL!##NSURL!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(NSError!) -> Void#>)
        
    }
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginButton.hidden = true;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "UpdateAfterFirstLogin", name: "loginSuccessful", object: nil)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        print("viewdidload")
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            //session available
            print("session available");
            let sessionDataObj = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, callback: { (error:NSError!, renewedSession: SPTSession!) ->
                    Void in
                    if error == nil {
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        
                        self.session = renewedSession
                        
                        self.playUsingSession(renewedSession)
                    
                    }
                    else {
                        print("error refresshing session")
                    }
                })
                
                
            }else {
                print("sessionValid")
                playUsingSession(session)
            }
            
        } else {
            print("session not available");

            loginButton.hidden = false;
        }
        
        
        
    }
    
    func UpdateAfterFirstLogin() {
        loginButton.hidden = true;
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession") {
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            
            playUsingSession(firstTimeSession)
            
        }
        
        
    }
    
    func playUsingSession(sessionObj:SPTSession) {
        print("playing using session called")
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            
        }
        player?.loginWithSession(sessionObj, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("enabling playback got error")
                return
            }
            //SPTRequest.requestItemAtURI(<#T##uri: NSURL!##NSURL!#>, withSession: <#T##SPTSession!#>, callback: <#T##SPTRequestCallback!##SPTRequestCallback!##(NSError!, AnyObject!) -> Void#>)
            //SPTTrack.trackWithURI(<#T##uri: NSURL!##NSURL!#>, session: <#T##SPTSession!#>, callback: <#T##SPTRequestCallback!##SPTRequestCallback!##(NSError!, AnyObject!) -> Void#>)
            
            self.addSongtoPlaylist("3KUs7BeZGMze6HDDdFlb7j") //loveland
            self.addSongtoPlaylist("24w8CSNGN34hYPCrjdRLob") //fairytale
            
            SPTTrack.trackWithURI(NSURL(string: "spotify:track:3f9zqUnrnIq0LANhmnaF0V"), session: sessionObj, callback: { (error:NSError!, trackObj:AnyObject!) -> Void in
                if error != nil {
                    print("track lookup got error")
                    return
                }
                //let track = trackObj as! SPTTrack
                //self.player?.playTrackProvider(track, callback: nil)
                print("song will play lol")
                //self.player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                //self.player?.playURI(NSURL(string: "spotify:track:4gqgQQHynn86YrJ9dEuMfc"), callback: nil)
                
                self.player?.playURIs(self.userPlaylistTrackStrings, fromIndex: 0, callback: nil)
                //self.player?.play
                //self.player?.playURI(<#T##uri: NSURL!##NSURL!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(NSError!) -> Void#>)
            })
            /*
            SPTRequest.requestItemAtURI(NSURL(string: "spotfiy:track:3f9zqUnrnIq0LANhmnaF0V"), withSession: sessionObj, callback: { (error:NSError!, albumObj:AnyObject!) -> Void in
                if error != nil {
                    print("album lookup got error")
                    return
                }
                let album = albumObj as! SPTAlbum
                self.player?.playTrackProvider(album, callback: nil)
            })*/
            
        })
    }
    

    @IBAction func loginWithSpotify(sender: AnyObject) {
        print("buttonclicked");
        let auth = SPTAuth.defaultInstance()
        auth.clientID = kClientID;
        auth.redirectURL = NSURL(string: kCallBackURL);
        auth.requestedScopes = [SPTAuthStreamingScope];
        let loginURL : NSURL = auth.loginURL;
       // let loginURL = SPTAuth.loginURLForClientId(kClientID, withRedirectURL: NSURL(string: kCallBackURL), scopes: [SPTAuthStreamingScope], responseType: "code")
        
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_MSEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            print(UIApplication.sharedApplication().openURL(loginURL))
        })
        
        

        
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    
    


}

