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
    fileprivate func makeParameters(from params:[String:Any] = [:], apiKey:Bool = true) -> Parameters {
        var query = params as Parameters
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
    
    /**
     returns a DataRequest created using the list of parameters
     - parameters:
        - url: api url
        - method: HTTPMethod for the request
        - paramteters: optional Parameters for the reqeust
        - headers: optional HTTPHeaders for the request
     */
    fileprivate func dataRequest(url: URL, method:HTTPMethod, paramteters:Parameters? = nil, headers:HTTPHeaders? = nil) -> DataRequest{
        let request = Alamofire.request(url, method: method, parameters: paramteters, encoding: URLEncoding(destination: .queryString), headers: headers)
        return request
    }
    
    /// Parses API response data and calls completion closures
    fileprivate func parseAPI(_ response:DataResponse<Any>, completion: @escaping(Movies?) -> Void) {
        if let status = response.response?.statusCode {
            switch(status){
            case 200 ... 299:
                print("example success")
            default:
                print("error with response status: \(status)")
                completion(nil)
                return
            }
        }
        if let data = response.data {
            do {
                let movies = try JSONDecoder().decode(Movies.self, from: data)
                completion(movies)
            }
            catch {
                print("Error while parsing the data")
                completion(nil)
            }
            
        }
    }
    
    /// Fetches list of Popular movies with specified page number
    func getPopularMovies(page:Int, completion: @escaping (Movies?)-> Void) {
        let parameters = makeParameters(from: ["page":page])
        if let apiURL = url(for: TwentyFourConstants.popularAPI) {
            dataRequest(url: apiURL, method: .get, paramteters: parameters).validate().responseJSON { (response) in
                self.parseAPI(response, completion: completion)
            }
        }
    }
    
    /// Fetches list of movies in specified release year & page number
    func searchMovie(by year:String, page:Int = 1, completion: @escaping (Movies?)-> Void) {
        let parameters = makeParameters(from: ["page":page,"primary_release_year":year,"sort_by":"vote_average.desc"])
        if let apiURL = url(for: TwentyFourConstants.discoverAPI) {
            dataRequest(url: apiURL, method: .get, paramteters: parameters).validate().responseJSON { response in
                self.parseAPI(response, completion: completion)
            }
        }
    }
    
    /// Fetches details for the provided movie ID
    func getDetailsForMovie(with id:String, completion:@escaping (MovieDetails?)->Void){
        let detail_api_path = String(format: TwentyFourConstants.movieDetailAPI, id)
        let parameters = makeParameters()
        if let apiURL = url(for: detail_api_path) {
            dataRequest(url: apiURL, method: .get, paramteters: parameters).validate().responseJSON { (response) in
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
            dataRequest(url: apiURL, method: .get, paramteters: parameters).validate().responseJSON { response in
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
