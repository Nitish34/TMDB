//
//  TMDB_SearchMoviewVC.swift
//  TMDB
//
//  Created by SmartConnect Technologies on 07/03/21.
//

import UIKit
import RxCocoa
import RxSwift

class TMDB_SearchMoviewVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var movieSearchViewViewModel: TMDB_MovieSearchVM!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let searchBar = self.navigationItem.searchController!.searchBar
        
        movieSearchViewViewModel = TMDB_MovieSearchVM(query: searchBar.rx.text.orEmpty.asDriver(), movieService: AuthStore.shared)
        
        movieSearchViewViewModel.movies.drive(onNext: {[unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        movieSearchViewViewModel.isFetching.drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
    
        movieSearchViewViewModel.info.drive(onNext: {[unowned self] (info) in
            self.infoLabel.isHidden = !self.movieSearchViewViewModel.hasInfo
            self.infoLabel.text = info
        }).disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] in
                searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] in
                searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        setupTableView()
    }
    
    //MARK: Navigationbar Setup
    private func setupNavigationBar() {
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.white

        let appearance = UINavigationBarAppearance()
              appearance.backgroundColor = .black
              appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
              navigationController?.navigationBar.tintColor = .white
              navigationController?.navigationBar.standardAppearance = appearance
              navigationController?.navigationBar.compactAppearance = appearance
              navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: Tableview Setup
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}
extension TMDB_SearchMoviewVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieSearchViewViewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        if let viewModel = movieSearchViewViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        return cell
    }
        
}
