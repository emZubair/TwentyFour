//
//  MovieDetail.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import Foundation
typealias Codeable = Codable & Decodable

public struct Movie {
    let id:Int
    let title:String
    let poster:String
    
    init(json:[String:Any]) {
        id = json["id"] as? Int ?? -1
        title = json["title"] as? String ?? ""
        poster = json["poster_path"] as? String ?? ""
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
        return movie.id
    }
    
    func title() -> String {
        return movie.title
    }
    
    func poster() -> String {
        return movie.poster
    }
}
