//
//  APIClient.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import Foundation
import Alamofire

final class APIClient {
    let TIME_OUT_INTERVAL:Double = 20
    //MARK: - Shared Instance
    static let sharedInstance = APIClient()
    
    //MARK: - Private Methods
    private init(){}
    
    
    /**
     makes a Parameters for a given dictionary of params
     - parameters:
        - params: dictionary of params defaults to nil
        - apiKey: flag to include api_key or not defaults to true
     */
    fileprivate func makeParameters(from params:[String:Any]? = nil, apiKey:Bool = true) -> Parameters {
        var query:Parameters = [:]
        if let params = params {
            for (key,value) in params{
                query[key] = value
            }
        }
        if apiKey {
            query["api_key"] = TwentyFourConstants.apiKey
        }
        return query
    }
    
    /**
     makes a URL for a given API path string
     - parameters:
     - api: path for the API to target
     */
    fileprivate func url(for api:String) -> URL? {
        let apiPath = TwentyFourConstants.basePath + api
        if let apiURL = URL(string: apiPath) {
            print("Fetch URL:\(apiURL.absoluteString)")
            return apiURL
        }
        return nil
    }
    
    /// Parses API response data and calls completion closures
    fileprivate func parseAPI(_ response:DataResponse<Any>, completion: @escaping(Int,Int,[Movie]?) -> Void) {
        guard response.result.isSuccess else {
            completion(-1,-1, nil)
            return
        }
        guard let value = response.result.value as? [String: Any],
            let results = value["results"] as? [[String: Any]] else {
                print("Malformed data received from fetch popular service")
                completion(-1,-1,nil)
                return
        }
        let movies = results.compactMap{ movie  in
            Movie(json: movie)
        }
        let page = value["page"] as? Int ?? 1
        let total_pages = value["total_pages"] as? Int ?? 1
        completion(page,total_pages,movies)
    }
    
    /// Fetches list of Popular movies with specified page number
    func getPopularMovies(page:Int, completion: @escaping (Int,Int,[Movie]?)-> Void) {
        let parameters = makeParameters(from: ["page":page])
        if let apiURL = url(for: TwentyFourConstants.popularAPI) {
            Alamofire.request(apiURL, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).validate().responseJSON { (response) in
                self.parseAPI(response, completion: completion)
            }
        }
    }
    
    /// Fetches list of movies in specified release year & page number
    func searchMovie(by year:String, page:Int = 1, completion: @escaping (Int,Int,[Movie]?)-> Void) {
        let parameters = makeParameters(from: ["page":page,"primary_release_year":year,"sort_by":"vote_average.desc"])
        if let apiURL = url(for: TwentyFourConstants.discoverAPI) {
            Alamofire.request(apiURL, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).validate().responseJSON { response in
                self.parseAPI(response, completion: completion)
            }
        }
    }
    
    /// Fetches details for the provided movie ID
    func getDetailsForMovie(with id:String, completion:@escaping (MovieDetails?)->Void){
        let detail_api_path = String(format: TwentyFourConstants.movieDetailAPI, id)
        let parameters = makeParameters()
        if let apiURL = url(for: detail_api_path) {
            Alamofire.request(apiURL, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).validate().responseJSON { (response) in
                guard response.result.isSuccess else {
                    completion(nil)
                    return
                }
                guard let result = response.result.value as? [String: Any]
                    else {
                        print("Malformed data received from fetch movie details service")
                        completion(nil)
                        return
                }
                let movieDetails = MovieDetails(json: result)
                completion(movieDetails)
            }
        }
    }
    
    /// Fetches YouTube Identifier for the provided movie ID
    func getYouTubeIDFor(movie:String, completion: @escaping (String?)-> Void) {
        let youtube_id_api_path = String(format: TwentyFourConstants.youTubeLinkAPI, movie)
        let parameters = makeParameters()
        if let apiURL = url(for: youtube_id_api_path) {
            Alamofire.request(apiURL, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).validate().responseJSON { response in
                guard response.result.isSuccess else {
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                    let result = value["results"] as? [[String: Any]] else {
                        print("Malformed data received from fetch youtubelink service")
                        completion(nil)
                        return
                }
                let video_id = result.first?["key"] as? String ?? ""
                completion(video_id)
            }
        }
    }
    
}
