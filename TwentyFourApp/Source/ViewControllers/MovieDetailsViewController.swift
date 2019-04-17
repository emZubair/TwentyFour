//
//  MovieDetailsViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/17/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit
import GradientCircularProgress

class MovieDetailsViewController : UIViewController {
    
    var movieID:Int? = nil
    
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
        self.title = "MOVIE_DETAILS".localize()
        self.navigationController?.navigationBar.backItem?.title = "MOVIE_CATALOG".localize()
        self.loadMovieDetails()
    }
    
    //MARK: - private Methods
    fileprivate func setViewData(with movieDetails:MovieDetails) {
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
    }
    fileprivate func loadMovieDetails() {
        ProgressLoader.showProgressLoader(with: "LOADING_DETAILS".localize(), bgStyle:.dark)
        if let id = movieID {
            APIClient.sharedInstance.getDetailsForMovie(with: String(id)) { details in
                if let detail = details {
                    self.setViewData(with: detail)
                } else {
                }
                ProgressLoader.hideProgressLoader()
            }
        }
    }
    
    @IBAction func watchTrailerTapped(_ sender: UIButton) {
        print("showing Trailer")
    }
}
