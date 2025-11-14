//
//  ViewState.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

enum ViewState<Content> {
    case idle
    case loading
    case content(Content)
    case error(String)
}

extension ViewState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case let .error(message) = self { return message }
        return nil
    }
}
