import SwiftUI
import UIKit

struct AsyncImageView: View {
    let url: URL?
    let accessibilityDescription: String
    var reloadToken: UUID = UUID()

    @State private var phase: Phase = .empty

    private enum Phase: Equatable {
        case empty
        case image(Image)
        case failure
    }

    var body: some View {
        content
            .task(id: LoadKey(url: url, reload: reloadToken)) {
                await load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .image(let image):
            image
                .resizable()
                .scaledToFit()
                .accessibilityLabel(Text(accessibilityDescription))
                .accessibilityAddTraits(.isImage)

        case .failure:
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

        case .empty:
            ProgressView()
                .accessibilityHidden(true)
        }
    }

    private func load() async {
        guard let url else {
            phase = .failure
            return
        }

        phase = .empty

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 12
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)

        do {
            let (data, _) = try await session.data(from: url)
            guard !Task.isCancelled else { return }
            if let uiImage = UIImage(data: data) {
                phase = .image(Image(uiImage: uiImage))
            } else {
                phase = .failure
            }
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failure
        }
    }

    private struct LoadKey: Hashable {
        let url: URL?
        let reload: UUID
    }
}
