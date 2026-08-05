//
//  RecommendationByIDView.swift
//  Musadora
//
//  Created by Rudrank Riyam on 05/08/26.
//

import MusadoraKit
import MusicKit
import SwiftUI

struct RecommendationByIDView: View {
  @State private var recommendations: MusicRecommendations = []
  @State private var selected: MusicRecommendationItem?
  @State private var isLoading = false

  var body: some View {
    List {
      Section {
        if isLoading {
          ProgressView().frame(maxWidth: .infinity, alignment: .leading)
        }

        ForEach(recommendations) { recommendation in
          Button {
            Task { await fetchByID(recommendation.id) }
          } label: {
            VStack(alignment: .leading, spacing: 2) {
              Text(recommendation.title ?? "Untitled")
                .foregroundStyle(.primary)

              Text(recommendation.id.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
        }
      } header: {
        Text("Default Recommendations")
      } footer: {
        Text("Tap any row to re-fetch just that recommendation by its identifier.")
      }

      if let selected {
        Section("Fetched by ID") {
          LabeledContent("Title", value: selected.title ?? "Untitled")
          LabeledContent("Identifier", value: selected.id.rawValue)
          LabeledContent("Albums", value: "\(selected.albums.count)")
          LabeledContent("Playlists", value: "\(selected.playlists.count)")
          LabeledContent("Stations", value: "\(selected.stations.count)")

          if let nextRefreshDate = selected.nextRefreshDate {
            LabeledContent("Next Refresh", value: nextRefreshDate.formatted(date: .abbreviated, time: .shortened))
          }
        }
      }
    }
    .navigationTitle("Recommendation by ID")
    .task { await loadDefaults() }
  }
}

extension RecommendationByIDView {
  private func loadDefaults() async {
    isLoading = true
    defer { isLoading = false }

    do {
      recommendations = try await MRecommendation.default()
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func fetchByID(_ id: MusicItemID) async {
    do {
      selected = try await MRecommendation.recommendation(id: id)
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }
}

#Preview {
  NavigationStack {
    RecommendationByIDView()
  }
}
