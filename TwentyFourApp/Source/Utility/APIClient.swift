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
    
    fileprivate func makeRequest(for api:String) -> URLRequest? {
        let apiPath = String(format: TwentyFourConstants.basePath, api)
        if let apiURL = URL(string: apiPath) {
            print("Fetch URL:\(apiURL.absoluteString)")
            var request = URLRequest(url: apiURL)
            request.timeoutInterval = TIME_OUT_INTERVAL
            return request
        }
        return nil
    }
    
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
    
    func getPopularMovies(page:Int, completion: @escaping (Int,Int,[Movie]?)-> Void) {
        let popular_api_path = String(format: TwentyFourConstants.popularPath, page)
        if let request = makeRequest(for: popular_api_path) {
            Alamofire.request(request).validate().responseJSON { response in
                self.parseAPI(response, completion: completion)
            }
        }
    }
    
    
    func searchMovie(by year:String, page:Int = 1, completion: @escaping (Int,Int,[Movie]?)-> Void) {
        let discover_api_path = String(format: TwentyFourConstants.discover_path, arguments: [year ,String(page)])
        if let request = makeRequest(for: discover_api_path) {
            Alamofire.request(request).validate().responseJSON { response in
                self.parseAPI(response, completion: completion)
            }
        }
    }
    
    func getDetailsForMovie(with id:String, completion:@escaping (MovieDetails?)->Void){
        let detail_api_path = String(format: TwentyFourConstants.movie_detail, id)
        if let request = makeRequest(for: detail_api_path) {
            Alamofire.request(request).validate().responseJSON { response in
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
    
    func getYouTubeIDFor(movie:String, completion: @escaping (String?)-> Void) {
        let youtube_id_api_path = String(format: TwentyFourConstants.youTubeLinkAPI, movie)
        if let request = makeRequest(for: youtube_id_api_path) {
            Alamofire.request(request).validate().responseJSON { response in
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
