//
//  LoadingStateHandler.swift
//  OptimalPint
//
//  Created by James Harvey on 04/12/2025.
//

import ErrorKit
import SwiftUI

struct LoadingStateHandler<T, LoadedContent: View, LoadingContent: View, ErrorContent: View>: View {
    let loadingState: LoadingState<T>

    let loadedView: (T) -> LoadedContent
    let loadingView: LoadingContent
    let errorView: (Error) -> ErrorContent

    init(
        loadingState: LoadingState<T>,
        @ViewBuilder loadedView: @escaping (T) -> LoadedContent,
        @ViewBuilder loadingView: () -> LoadingContent = { ProgressView() },
        @ViewBuilder errorView: @escaping (Error) -> ErrorContent = { error in
            ContentUnavailableView(
                "Failed to Fetch Data",
                systemImage: "exclamationmark.circle.fill",
                description: Text(ErrorKit.userFriendlyMessage(for: error))
            )
        }
    ) {
        self.loadingState = loadingState
        self.loadedView = loadedView
        self.loadingView = loadingView()
        self.errorView = errorView
    }

    var body: some View {
        switch loadingState {
        case .initial, .loading:
            loadingView
        case .error(let error):
            errorView(error)
        case .loaded(let value):
            loadedView(value)
        }
    }
}

#Preview {
    LoadingStateHandler(loadingState: .loaded("Hello!")) { value in
        Text("\(value)")
    }
}
