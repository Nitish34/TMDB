//
//  TMDB_MovieSearchVM.swift
//  TMDB
//
//  Created by SmartConnect Technologies on 07/03/21.
//

import Foundation
import RxSwift
import RxCocoa

class TMDB_MovieSearchVM {
    
    private let movieService: APIService
    private let disposeBag = DisposeBag()
    
    init(query: Driver<String>, movieService: APIService) {
        self.movieService = movieService
        query
            .throttle(.milliseconds(Int(1.0)))
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (queryString) in
                self?.searchMovie(query: queryString)
                if queryString.isEmpty {
                    self?._movies.accept([])
                    self?._info.accept("Start searching your favorite movies")
                }
            }).disposed(by: disposeBag)
    }
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    
    var info: Driver<String?> {
        return _info.asDriver()
    }
    
    var hasInfo: Bool {
        return _info.value != nil
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
    
    private func searchMovie(query: String?) {
        guard let query = query, !query.isEmpty else {
            return
        }
        
        self._movies.accept([])
        self._isFetching.accept(true)
        self._info.accept(nil)
        
        movieService.searchMovie(query: query, params: nil, successHandler: {[weak self] (response) in
            
            self?._isFetching.accept(false)
            if response.totalResults == 0 {
                self?._info.accept("No result for \(query)")
            }
            self?._movies.accept(Array(response.results.prefix(5)))
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._info.accept(error.localizedDescription)
        }
    }
}
