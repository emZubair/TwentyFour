//
//  MovieDetail.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import Foundation

public struct Movie : Decodable{
    
    var id:Int?
    var title:String?
    var poster:String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster = "poster_path"
    }
    
    init(json:[String:Any]) {
        id = json["id"] as? Int ?? -1
        title = json["title"] as? String ?? ""
        poster = json["poster_path"] as? String ?? ""
    }
}

public struct Movies: Decodable {
    var page: Int
    let totalPages:Int
    var listOfMovies:[Movie]
    
    func hasBackPage() -> Bool {
        return page > 1
    }
    
    func hasNextPage() -> Bool {
        return page < totalPages
    }
    
    
    fileprivate mutating func removeMoviesWithNullPoster() {
        listOfMovies =  listOfMovies.filter { movie in movie.poster != nil}
    }
    
    mutating func hasMovies() -> Bool {
        removeMoviesWithNullPoster()
        return listOfMovies.count > 0
    }
    
    mutating func incrementPage() {
        page += 1
    }
    
    mutating func decrementPage() {
        page -= 1
    }
    
    mutating func resetPage() {
        page = 1
    }
    
    func movie(for index:Int) -> Movie? {
        if index < listOfMovies.count {
            return listOfMovies[index]
        }
        return nil
    }
    
    func moviesCount() -> Int {
        return listOfMovies.count
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case listOfMovies = "results"
    }
}

public struct MovieDetails {
    let movie:Movie
    let genre:String
    let date:String
    let overview:String
    let trailerURL:String?
    
    
    
    init(json:[String:Any]) {
        movie = Movie(json: json)
        date = json["release_date"] as? String ?? ""
        if let genres = json["genres"] as? [[String:Any]] {
            genre = genres.compactMap({ dic in
                return dic["name"] as? String ?? ""
            }).joined(separator: ", ")
        }else {
            genre = ""
        }
        overview = json["overview"] as? String ?? ""
        trailerURL = nil
    }
    
    func id() -> Int {
        return movie.id ?? 1
    }

    func title() -> String {
        return movie.title ?? ""
    }

    func poster() -> String {
        return movie.poster ?? ""
    }
}
