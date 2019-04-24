//
//  MovieCatalogViewController.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit

class MovieCatalogViewController: BaseViewController {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var catalogTableView: UITableView!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    @IBOutlet weak var previousBtn: UIBarButtonItem!
    fileprivate var refreshControl:UIRefreshControl!
    

    var movies:Movies? = nil
    var year:String? = nil
    var cellHeight:CGFloat!
    var networkStatus:NetworkStatusUtility!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkStatus = NetworkStatusUtility()
        networkStatus.startNetworkReachabilityObserver()
        searchBar.translatesAutoresizingMaskIntoConstraints = true
        catalogTableView.delegate = self
        catalogTableView.dataSource = self
        searchBar.delegate = self
        viewSetUp()
    }
    
    func adjustSize() {
        let bounds = UIScreen.main.bounds
        cellHeight = bounds.height
        cellHeight *= bounds.height > bounds.width ?  0.13 : 0.25
        let fontSize = bounds.height * 0.025
        refreshControl.attributedTitle = NSAttributedString(string: "PULL_TO_REFRESH".localize(), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])

    }
    
    fileprivate func viewSetUp() {
        refreshControl = UIRefreshControl(frame: catalogTableView.bounds)
        refreshControl.addTarget(self, action: #selector(MovieCatalogViewController.refresh(sender:)), for: UIControl.Event.valueChanged)
        catalogTableView.addSubview(refreshControl)
        adjustSize()
        searchBar.placeholder = "NAME_TO_SEARCH".localize()
        searchBar.inputAccessoryView = keyboardAccessoryView()
        nextBtn.title = "NEXT".localize()
        previousBtn.title = "BACK".localize()
        NotificationCenter.default.addObserver(self, selector: #selector(MovieCatalogViewController.checkInternetAndLoadContent), name: Notification.Name(rawValue: "NetworkReachAbilityChanged"), object: nil)
        checkInternetAndLoadContent()
    }
    
    fileprivate func stopResfreshin() {
        refreshControl.endRefreshing()
    }
    
    /// Refersh content via Pull & refresh
    @objc func refresh(sender:AnyObject) {
        if networkStatus.shouldProceed(from: self) {
            movies?.resetPage()
            loadMoviesCatalog()
        }else {
            stopResfreshin()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func checkInternetAndLoadContent() {
        if networkStatus.isConnected() {
            loadMoviesCatalog()
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        updateTitle(with: "MOVIE_CATALOG".localize())
        let bounds = UIScreen.main.bounds
        let frame = searchBar.frame
        searchBar.frame = CGRect(origin: frame.origin, size: CGSize(width: bounds.width * 0.60, height: searchBar.bounds.height))
    }
    
    //MARK: - private Methods
    fileprivate func updateTitle(with text:String) {
        self.navigationController?.navigationBar.topItem?.title = text
    }
    
    fileprivate func showingPopularMovies() -> Bool {
        return navigationController?.navigationBar.topItem?.title == "MOVIE_CATALOG".localize() ? true : false
    }
    
    /// Enable/Disable buttons depending upn the page number
    fileprivate func updateButtonsAndBar() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        previousBtn.isEnabled = movies?.hasBackPage() ?? false
        nextBtn.isEnabled = movies?.hasNextPage() ?? false
    }
    
    fileprivate func reloadTableView() {
        let progress = String(format: "SHOWING_MOVIES".localize(), movies?.page ?? 1, movies?.totalPages ?? 1)
        makeBasicToastWithForTableViews(text: progress, duration: 1)
        catalogTableView.reloadData()
        ProgressLoader.hideProgressLoader()
    }
    
    /// Loads Popular movies
    fileprivate func loadMoviesCatalog() {
        if ProgressLoader.isShowing() {
            return
        }
        searchBar.resignFirstResponder()
        ProgressLoader.showProgressLoader(with: "LOADING_MOVIES".localize())
        APIClient.sharedInstance.getPopularMovies(page: movies?.page ?? 1) { fetchedMovies in
            self.updateViewDataWith(movies: fetchedMovies, title: "MOVIE_CATALOG".localize())
        }
    }
    
    
     /// Loads movies by year
    fileprivate func loadMovies(by year:String) {
        let message = String(format: "LOADING_YEAR".localize(), year)
        ProgressLoader.showProgressLoader(with: message)
        APIClient.sharedInstance.searchMovie(by: year, page: movies?.page ?? 1) { fetchedMovies in
            let view_title = String(format: "RELEASED_IN_YEAR".localize(), year)
            self.updateViewDataWith(movies: fetchedMovies, title: view_title)
        }
    }
    
    
    /// Populates tableView with fetched data
    fileprivate func updateViewDataWith(movies:Movies?, title:String) {
        ProgressLoader.hideProgressLoader()
        stopResfreshin()
        if var movies = movies{
            if movies.hasMovies() {
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
        if networkStatus.shouldProceed(from: self) {
            if let movies = movies, let movie = movies.movie(for: index) {
                let movieID = movie.id
                let detailViewController = ViewControllerLoader.loadViewController(of: MovieDetailsViewController.self, with: .MovieDetailsViewController)
                detailViewController.movieID = movieID
                self.navigationController?.show(detailViewController, sender: self)
            }
        }
    }
    
    /**
     Loads the next page from movies list
     Before fetching check which API to fetch from
    */
    fileprivate func loadPageInSelectedCategory() {
        showingPopularMovies() ? loadMoviesCatalog() : loadMovies(by: year!)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if networkStatus.shouldProceed(from: self) {
            movies?.incrementPage()
            loadPageInSelectedCategory()
        }
    }
    @IBAction func previousButtonTapped(_ sender: Any) {
        if networkStatus.shouldProceed(from: self) {
            movies?.decrementPage()
            loadPageInSelectedCategory()
        }
    }
    
    /// Provides Toolbar with Done Button, appened with Keyboard
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
            if networkStatus.shouldProceed(from: self) {
                loadMovies(by: year)
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
        return movies?.moviesCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCatalogCell.identifier, for: indexPath) as! MovieCatalogCell
        if let movies = movies, let movie = movies.movie(for: indexPath.row) {
            cell.updateCellUI(with: movie)
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
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showDetailsForMovieSelected(at: indexPath.row)
    }
}

//MARK: - UISearchBar delegate Methods
extension MovieCatalogViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doneTapped()
    }
}
