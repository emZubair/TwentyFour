//
//  APIClient.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    
    //MARK: - Shared Instance
    static let sharedInstance = APIClient()
    
    //MARK: - Private Methods
    private init(){}
    
    fileprivate func url(for api:String) -> URL? {
        let apiPath = String(format: TwentyFourConstants.serverURL, api)
        
        if let apiURL = URL(string: apiPath) {
            print("Fetching from URL:\(apiURL.absoluteString)")
            return apiURL
        }
        return nil
    }
    
    func getPopularMovies(page:Int, completion: @escaping (Int,Int,[Movie]?)-> Void) {
        if let url = url(for: (TwentyFourConstants.apiPopularMovies)) {
            Alamofire.request(url).validate().responseJSON { response in
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
            }
    }
    
    func getDetailsForMovie(with id:String, completion:@escaping (MovieDetails?)->Void){
        if let url = url(for: id) {
            Alamofire.request(url).validate().responseJSON { response in
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
        let youTubeAPI = String(format: TwentyFourConstants.youTubeLinkAPI, movie)
        if let url = url(for: youTubeAPI) {
            Alamofire.request(url).validate().responseJSON { response in
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
