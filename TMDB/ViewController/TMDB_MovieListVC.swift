//
//  TMDB_MovieListVC.swift
//  TMDB
//
//  Created by SmartConnect Technologies on 07/03/21.
//

import UIKit
import RxCocoa
import RxSwift

class TMDB_MovieListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var movieListViewModel : TMDB_MovieListViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
         
        movieListViewModel = TMDB_MovieListViewModel(endpoint: segmentedControl.rx.selectedSegmentIndex
            .map { Endpoint(index: $0) ?? .nowPlaying }
            .asDriver(onErrorJustReturn: .nowPlaying)
            , movieService: AuthStore.shared)

        movieListViewModel.movies.drive(onNext: {[unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)

        movieListViewModel.isFetching.drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        movieListViewModel.error.drive(onNext: {[unowned self] (error) in
            self.infoLabel.isHidden = !self.movieListViewModel.hasError
            self.infoLabel.text = error
        }).disposed(by: disposeBag)
        
        setupTableView()
        
        let appearance = UINavigationBarAppearance()
              appearance.backgroundColor = .black
              navigationController?.navigationBar.standardAppearance = appearance
    }
    
    //MARK: Tableview Setup
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }

}
extension TMDB_MovieListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieListViewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        if let viewModel = movieListViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        return cell
    }
}
