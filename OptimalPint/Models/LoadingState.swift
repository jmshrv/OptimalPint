//
//  LoadingState.swift
//  OptimalPint
//
//  Created by James Harvey on 04/12/2025.
//

enum LoadingState<T> {
    /// Data hasn't been fetched yet.
    case initial
    
    /// A fetch is in progress
    case loading
    
    /// Data has successfully loaded
    case loaded(T)
    
    /// An error occured during loading
    case error(Error)
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}
