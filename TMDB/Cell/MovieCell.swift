//
//  MovieCell.swift
//  TMDB
//
//  Created by SmartConnect Technologies on 07/03/21.
//

import UIKit
import Kingfisher

class MovieCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func configure(viewModel: TMDB_MovieViewModel) {
        titleLabel.text = viewModel.title
        overviewLabel.text = viewModel.overview
        releaseDateLabel.text = viewModel.releaseDate
        ratingLabel.text = viewModel.rating
        posterImageView.kf.setImage(with: viewModel.posterURL)
        posterImageView.layer.cornerRadius = 5.0
        posterImageView.layer.masksToBounds = true
    }
}

