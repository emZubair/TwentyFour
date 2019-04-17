//
//  Constants.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit

final class TwentyFourConstants {
    static let movieCellID = "movieCell"
    static let api_key = "242be8cc853e2f3e7f2a12687b951da8"
    static let apiPopularMovies = "popular"
    static let serverURL = "https://api.themoviedb.org/3/movie/%@?api_key=242be8cc853e2f3e7f2a12687b951da8"
    static let posterURL = "https://image.tmdb.org/t/p/w300_and_h450_bestv2/"
    
}

extension String {
    /**
     To get the localized string for the provided string,
     string value will be used if localized version not found.
     */
    func localize() -> String {
        return NSLocalizedString(self, comment: self)
    }
}

enum StoryBoardIdentifier:String {
    case MovieDetailsViewController = "MovieDetailsViewController"
}

class ViewControllerLoader {
    static func loadViewController<T>(of type:T.Type, with id:StoryBoardIdentifier) -> T where T : UIViewController {
        let viewcontroller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: id.rawValue) as! T
        return viewcontroller
    }
}
