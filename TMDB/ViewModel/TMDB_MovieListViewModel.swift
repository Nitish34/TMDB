//
//  TMDB_MovieListViewModel.swift
//  TMDB
//
//  Created by SmartConnect Technologies on 07/03/21.
//

import Foundation
import RxCocoa
import RxSwift

class TMDB_MovieListViewModel {
    
    private let movieService: APIService
    private let disposeBag = DisposeBag()
    
    init(endpoint: Driver<Endpoint>, movieService: APIService) {
        self.movieService = movieService
        endpoint
            .drive(onNext: { [weak self] (endpoint) in
                self?.fetchMovies(endpoint: endpoint)
        }).disposed(by: disposeBag)
    }
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _error = BehaviorRelay<String?>(value: nil)
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    
    var error: Driver<String?> {
        return _error.asDriver()
    }
    
    var hasError: Bool {
        return _error.value != nil
    }
    
    var numberOfMovies: Int {
        return _movies.value.count
    }
    
    func viewModelForMovie(at index: Int) -> TMDB_MovieViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        return TMDB_MovieViewModel(movie: _movies.value[index])
    }
    
    private func fetchMovies(endpoint: Endpoint) {
        self._movies.accept([])
        self._isFetching.accept(true)
        self._error.accept(nil)
        
        movieService.fetchMovies(from: endpoint, params: nil, successHandler: {[weak self] (response) in
            self?._isFetching.accept(false)
            self?._movies.accept(response.results)
            
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._error.accept(error.localizedDescription)
        }
    }
    
}
