//
//  MovieCatalogViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit

class MovieCatalogViewController: UITableViewController {
    @IBOutlet var catalogTableView: UITableView!
    
    var movies:[Movie]?
    var currentPage = 1
    var totalPages:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "MOVIE_CATALOG".localize()
        self.loadMoviesCatalog()
    }
    
    //MARK: - private Methods
    fileprivate func reloadTableView() {
        catalogTableView.reloadData()
    }
    
    fileprivate func loadMoviesCatalog() {
        ProgressLoader.showProgressLoader()
        APIClient.sharedInstance.getPopularMovies(page: 1) { page,totalPages, fetchedMovies in
            self.currentPage = page
            self.totalPages = totalPages
            if let movies = fetchedMovies{
                self.movies = movies
                self.reloadTableView()
            }
            ProgressLoader.hideProgressLoader()
        }
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
extension MovieCatalogViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MovieCatalogCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCatalogCell.identifier, for: indexPath) as! MovieCatalogCell
        if let movies = movies {
            cell.updateCellUI(with: movies[indexPath.row])
        }
        return cell
    }
    
}

//MARK: - TableViewDelegate Methods
extension MovieCatalogViewController {

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showDetailsForMovieSelected(at: indexPath.row)
    }
}

