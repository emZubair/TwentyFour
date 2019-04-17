//
//  MovieCatalogViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit

class MovieCatalogViewController: BaseViewController {
    @IBOutlet var catalogTableView: UITableView!
    
    var movies:[Movie]?
    var currentPage = 1
    var totalPages:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMoviesCatalog()
    }
    
    //MARK: - private Methods
    fileprivate func reloadTableView() {
        
        let progress = String(format: "SHOWING_MOVIES".localize(), self.currentPage, self.totalPages ?? 0)
        makeBasicToastWithForTableViews(text: progress)
        catalogTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "MOVIE_CATALOG".localize()
    }
    
    fileprivate func loadMoviesCatalog() {
        makeActivityToastAtCenter()
        APIClient.sharedInstance.getPopularMovies(page: 1) { page,totalPages, fetchedMovies in
            self.hideToastActivity()
            self.currentPage = page
            self.totalPages = totalPages
            if let movies = fetchedMovies{
                self.movies = movies
                self.reloadTableView()
            } else {
                self.showFailureToast()
            }
        }
    }
    
    fileprivate func showFailureToast() {
        self.makeBasicToastWithForTableViews(text: "FETCH_MOVIE_FAILURE".localize())
    }
    
    fileprivate func showDetailsForMovieSelected(at index:Int) {
        if let selectedMovie = movies?[index] {
            let movieID = selectedMovie.id
            let detailViewController = ViewControllerLoader.loadViewController(of: MovieDetailsViewController.self, with: .MovieDetailsViewController)
            detailViewController.movieID = movieID
            self.navigationController?.show(detailViewController, sender: self)
        }
    }
    
}

//MARK: - TableViewDataSource Methods
extension MovieCatalogViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCatalogCell.identifier, for: indexPath) as! MovieCatalogCell
        if let movies = movies {
            cell.updateCellUI(with: movies[indexPath.row])
        }
        return cell
    }
    
}

//MARK: - TableViewDelegate Methods
extension MovieCatalogViewController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showDetailsForMovieSelected(at: indexPath.row)
    }
}

