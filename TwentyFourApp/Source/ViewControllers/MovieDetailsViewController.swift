//
//  MovieDetailsViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/17/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit

class MovieDetailsViewController : BaseViewController {
    
    var movieID:Int? = nil
    var videoID:String? = nil
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var genreLbl: UILabel!
    @IBOutlet weak var overviewLbl: UILabel!
    @IBOutlet weak var dateValueLbl: UILabel!
    @IBOutlet weak var movieNameLbl: UILabel!
    @IBOutlet weak var genreValueLbl: UILabel!
    @IBOutlet weak var watchTrailerBtn: UIButton!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewTextView: UITextView!
    
    override func viewDidLoad() {
        title = "MOVIE_DETAILS".localize()
        navigationController?.navigationBar.topItem?.title = ""
        loadMovieDetails()
    }
    
    //MARK: - private Methods
    fileprivate func enableWatchTrailerButton() {
        print("Trailer available to play")
        watchTrailerBtn.isEnabled = true
    }
    
    /// Updates the Label font sizes as per Screen size
    fileprivate func updateFontSizeRelativeToScreen() {
        let screenHeight = UIScreen.main.bounds.height
        let boldFontSize = screenHeight * 0.025
        let simpleFontSize = screenHeight * 0.020
        
        dateLbl.font = UIFont.boldSystemFont(ofSize: boldFontSize)
        genreLbl.font = UIFont.boldSystemFont(ofSize: boldFontSize)
        overviewLbl.font = UIFont.boldSystemFont(ofSize: boldFontSize)
        movieNameLbl.font = UIFont.boldSystemFont(ofSize: boldFontSize)
        
        dateValueLbl.font = UIFont.systemFont(ofSize: simpleFontSize)
        genreValueLbl.font = UIFont.systemFont(ofSize: simpleFontSize)
        overviewTextView.font = UIFont.systemFont(ofSize: simpleFontSize)
        watchTrailerBtn.titleLabel?.font = UIFont.systemFont(ofSize: simpleFontSize)
    }
    
    fileprivate func setViewData(with movieDetails:MovieDetails) {
        getYouTubeIDForTrailerVideo()
        updateFontSizeRelativeToScreen()
        movieNameLbl.text = movieDetails.title()
        if let url = URL(string: TwentyFourConstants.posterURL+movieDetails.poster()){
            posterImageView.kf.setImage(with: url)
        }
        dateLbl.text = "DATE".localize()
        genreLbl.text = "GENRES".localize()
        overviewLbl.text = "OVERVIEW".localize()
        dateValueLbl.text = movieDetails.date
        genreValueLbl.text = movieDetails.genre
        overviewTextView.text = movieDetails.overview
        watchTrailerBtn.setTitle("WATCH_TRAILER".localize(), for: .normal)
        watchTrailerBtn.isEnabled = false
    }
    
    /// Loads the Details for the selected Movie
    fileprivate func loadMovieDetails() {
        ProgressLoader.showProgressLoader(with: "LOADING_DETAILS".localize())
        if let id = movieID {
            APIClient.sharedInstance.getDetailsForMovie(with: String(id)) { details in
                if let detail = details {
                    self.setViewData(with: detail)
                } else {
                    self.makeBasicToastWith(text: "FETCH_MOVIE_DETAIL_FAILURE".localize())
                }
                ProgressLoader.hideProgressLoader()
            }
        }
    }
    
    /// Loads YouTube Identifier for the selected movie
    fileprivate func getYouTubeIDForTrailerVideo() {
        if let movie = movieID {
            APIClient.sharedInstance.getYouTubeIDFor(movie: String(movie)) { identifier in
                if let id = identifier {
                    self.videoID = id
                    self.enableWatchTrailerButton()
                }
            }
        }
    }
    
    @IBAction func watchTrailerTapped(_ sender: UIButton) {
        if NetworkStatusUtility().shouldProceed(from: self) {
            let youTubeVideoPlayer = YouTubePlayerViewController()
            self.navigationController?.show(youTubeVideoPlayer, sender: self)
            youTubeVideoPlayer.playVideo(videoIdentifier: videoID)
        }
    }
}
