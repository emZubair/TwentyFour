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
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    @IBOutlet weak var previousBtn: UIBarButtonItem!
    fileprivate var refreshControl:UIRefreshControl!
    var movies:[Movie]?
    var currentPage = 1
    var totalPages = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPage = 1
        totalPages = 1
        searchBar.translatesAutoresizingMaskIntoConstraints = true
        catalogTableView.delegate = self
        catalogTableView.dataSource = self
        searchBar.delegate = self
        viewSetUp()
    }
    
    fileprivate func viewSetUp() {
        refreshControl = UIRefreshControl(frame: catalogTableView.bounds)
        refreshControl.attributedTitle = NSAttributedString(string: "PULL_TO_REFRESH".localize())
        refreshControl.addTarget(self, action: #selector(MovieCatalogViewController.refresh(sender:)), for: UIControl.Event.valueChanged)
        catalogTableView.addSubview(refreshControl)
        searchBar.placeholder = "NAME_TO_SEARCH".localize()
        nextBtn.title = "NEXT".localize()
        previousBtn.title = "BACK".localize()
        self.loadMoviesCatalog()
        NotificationCenter.default.addObserver(self, selector: #selector(MovieCatalogViewController.networkStatusChanged), name: Notification.Name(rawValue: "NetworkReachAbilityChanged"), object: nil)
    }
    
    @objc func refresh(sender:AnyObject) {
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            currentPage = 1
            loadMoviesCatalog()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func networkStatusChanged() {
        if NetworkStatusUtility.shared.isConnected() {
            loadMoviesCatalog()
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        updateTitle(with: "MOVIE_CATALOG".localize())
    }
    
    //MARK: - private Methods
    fileprivate func updateTitle(with text:String) {
        self.navigationController?.navigationBar.topItem?.title = text
    }
    
    fileprivate func updateButtonsAndBar() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        previousBtn.isEnabled = currentPage > 1 ? true : false
        nextBtn.isEnabled = currentPage < totalPages ? true : false
    }
    
    fileprivate func reloadTableView() {
        let progress = String(format: "SHOWING_MOVIES".localize(), self.currentPage, self.totalPages)
        makeBasicToastWithForTableViews(text: progress, duration: 1)
        catalogTableView.reloadData()
        ProgressLoader.hideProgressLoader()
    }
    
    fileprivate func loadMoviesCatalog() {
        if ProgressLoader.isShowing() {
            return
        }
        searchBar.resignFirstResponder()
        ProgressLoader.showProgressLoader(with: "LOADING_MOVIES".localize())
        APIClient.sharedInstance.getPopularMovies(page: currentPage) { page,totalPages, fetchedMovies in
            self.updateViewDataWith(movies: fetchedMovies, page: page, totalPages: totalPages, title: "MOVIE_CATALOG".localize())
        }
    }
    
    fileprivate func updateViewDataWith(movies:[Movie]?, page:Int, totalPages:Int, title:String) {
        ProgressLoader.hideProgressLoader()
        refreshControl.endRefreshing()
        if let movies = movies{
            if movies.count > 1 {
                self.currentPage = page
                self.totalPages = totalPages
                self.movies = movies
                self.reloadTableView()
                self.updateTitle(with: title)
                self.updateButtonsAndBar()
            }else {
                searchBar.becomeFirstResponder()
                self.showInvalidYearToast()
            }
        } else {
            self.showFailureToast()
        }
        
    }
    
    fileprivate func show(movies:[Movie]?, page:Int, totalPages:Int) {
        
    }
    
    fileprivate func showFailureToast() {
        self.makeBasicToastWithForTableViews(text: "FETCH_MOVIE_FAILURE".localize())
    }
    
    fileprivate func showInvalidYearToast() {
        self.makeBasicToastWith(text: "INVALID_YEAR".localize(), position: .top, duration: 2)
    }
    
    fileprivate func showDetailsForMovieSelected(at index:Int) {
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            if let selectedMovie = movies?[index] {
                let movieID = selectedMovie.id
                let detailViewController = ViewControllerLoader.loadViewController(of: MovieDetailsViewController.self, with: .MovieDetailsViewController)
                detailViewController.movieID = movieID
                self.navigationController?.show(detailViewController, sender: self)
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            currentPage += 1
            loadMoviesCatalog()
        }
    }
    @IBAction func previousButtonTapped(_ sender: Any) {
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            currentPage -= 1
            loadMoviesCatalog()
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showDetailsForMovieSelected(at: indexPath.row)
    }
}

extension MovieCatalogViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count == 4 {
            if NetworkStatusUtility.shared.shouldProceed(from: self) {
                currentPage = 1
                ProgressLoader.showProgressLoader(with: "LOADING_MOVIES".localize())
                APIClient.sharedInstance.searchMovieBy(year: text, page: currentPage) { page,totalPages, fetchedMovies in
                    let view_title = String(format: "RELEASED_IN_YEAR".localize(), text)
                    self.updateViewDataWith(movies: fetchedMovies, page: page, totalPages: totalPages, title: view_title)
                }
            }
        }else {
            makeBasicToastWith(text: "YEAR_VALUE_ERROR".localize(), position: .top, duration: 1)
        }
    }
}
