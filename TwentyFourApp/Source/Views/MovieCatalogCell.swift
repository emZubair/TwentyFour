//
//  MovieCatalogCell.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/15/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCatalogCell : UITableViewCell {
    static let identifier = "movieCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
        
    func updateCellUI(with details:Movie) {
        titleLabel.text = details.title
        titleLabel.font = UIFont.systemFont(ofSize: self.bounds.height * 0.25)
        if let posterPath = details.poster, let url = URL(string: TwentyFourConstants.posterURL+posterPath){
            posterImageView.kf.setImage(with: url)
        }
        
    }
}
