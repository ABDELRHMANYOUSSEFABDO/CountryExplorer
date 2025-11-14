//
//  PullToRefreshView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct PullToRefreshView<Content: View>: View {
    let onRefresh: () async -> Void
    let content: Content
    
    @State private var isRefreshing = false
    
    init(
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        content
            .refreshable {
                await performRefresh()
            }
    }
    
    private func performRefresh() async {
        isRefreshing = true
        HapticManager.shared.light()
        await onRefresh()
        HapticManager.shared.success()
        isRefreshing = false
    }
}

