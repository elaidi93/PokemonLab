import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let accessibilityDescription: String

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
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
            @unknown default:
                Color.clear
                    .accessibilityHidden(true)
            }
        }
    }
}
