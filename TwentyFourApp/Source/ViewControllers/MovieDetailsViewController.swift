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
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscpe")
            containerScrollView.contentSize = UIScreen.main.bounds.size
        }
    }
    
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
    
    
    fileprivate func setViewData(with movieDetails:MovieDetails) {
        getYouTubeIDForTrailerVideo()
        movieNameLbl.text = movieDetails.title()
        movieNameLbl.font = UIFont.boldSystemFont(ofSize: 17)
        if let url = URL(string: TwentyFourConstants.posterURL+movieDetails.poster()){
            posterImageView.kf.setImage(with: url)
        }
        dateLbl.text = "DATE".localize()
        dateLbl.font = UIFont.boldSystemFont(ofSize: 17)
        genreLbl.text = "GENRES".localize()
        genreLbl.font = UIFont.boldSystemFont(ofSize: 17)
        overviewLbl.text = "OVERVIEW".localize()
        overviewLbl.font = UIFont.boldSystemFont(ofSize: 17)
        dateValueLbl.text = movieDetails.date
        genreValueLbl.text = movieDetails.genre
        overviewTextView.text = movieDetails.overview
        watchTrailerBtn.setTitle("WATCH_TRAILER".localize(), for: .normal)
        watchTrailerBtn.isEnabled = false
    }
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
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            let youTubeVideoPlayer = YouTubePlayerViewController()
            self.navigationController?.show(youTubeVideoPlayer, sender: self)
            youTubeVideoPlayer.playVideo(videoIdentifier: videoID)
        }
    }
}
