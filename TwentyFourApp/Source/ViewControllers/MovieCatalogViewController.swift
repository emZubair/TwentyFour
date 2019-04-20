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
    
    var totalPages = 1
    var movies:[Movie]?
    var currentPage = 1
    var year:String? = nil
    
    
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
        searchBar.inputAccessoryView = keyboardAccessoryView()
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
    
    fileprivate func showingPopularMovies() -> Bool {
        return navigationController?.navigationBar.topItem?.title == "MOVIE_CATALOG".localize() ? true : false
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
    
    fileprivate func loadMovies(by year:String, page number:Int) {
        let message = String(format: "LOADING_YEAR".localize(), year)
        ProgressLoader.showProgressLoader(with: message)
        APIClient.sharedInstance.searchMovie(by: year, page: number) { page,totalPages, fetchedMovies in
            let view_title = String(format: "RELEASED_IN_YEAR".localize(), year)
            self.updateViewDataWith(movies: fetchedMovies, page: page, totalPages: totalPages, title: view_title)
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
                if !showingPopularMovies() {
                    year = title.components(separatedBy: " ").last
                }
                self.updateButtonsAndBar()
            }else {
                self.showFailureToast(with: "NO_TITLES_FOUND")
            }
        } else {
            self.showFailureToast(with: "FETCH_MOVIE_FAILURE")
        }
        
    }
    
    fileprivate func showFailureToast(with message:String) {
        makeBasicToastWithForTableViews(text: message.localize())
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
    
    fileprivate func loadPageInSelectedCategory() {
        showingPopularMovies() ? loadMoviesCatalog() : loadMovies(by: year!, page: currentPage)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            currentPage += 1
            loadPageInSelectedCategory()
        }
    }
    @IBAction func previousButtonTapped(_ sender: Any) {
        if NetworkStatusUtility.shared.shouldProceed(from: self) {
            currentPage -= 1
            loadPageInSelectedCategory()
        }
    }
    
    func keyboardAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "DONE".localize(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MovieCatalogViewController.doneTapped))
        toolBar.setItems([spaceButton,doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        return toolBar
    }
    
    @objc func doneTapped() {
        if let year = searchBar.text, year.count == 4 {
            if NetworkStatusUtility.shared.shouldProceed(from: self) {
                loadMovies(by: year, page: 1)
                searchBar.resignFirstResponder()
                searchBar.text = ""
            }
        }else {
            makeBasicToastWith(text: "YEAR_VALUE_ERROR".localize(), position: .top, duration: 1)
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
        doneTapped()
    }
}
