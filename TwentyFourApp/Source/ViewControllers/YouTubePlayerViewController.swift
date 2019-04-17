//
//  YouTubePlayerViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/17/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//
import AVKit
import XCDYouTubeKit

struct YouTubeVideoQuality {
    static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
    static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
    static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
}

class YouTubePlayerViewController : UIViewController{
    var shouldDismissView:Bool = false
 
    func playVideo(videoIdentifier: String?) {
        let playerViewController = AVPlayerViewController()
        self.present(playerViewController, animated: true, completion: nil)
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                playerViewController?.player = AVPlayer(url: streamURL)
                NotificationCenter.default.addObserver(self, selector: #selector(self.videoEnded(notification:)), name: .AVPlayerItemDidPlayToEndTime, object:playerViewController?.player!.currentItem)

            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldDismissView {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldDismissView = true
    }
    
    @objc func videoEnded(notification:NSNotification) {
        self.navigationController?.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
