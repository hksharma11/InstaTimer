import ActivityKit
import SwiftUI
import WidgetKit

private let igPink = Color(red: 0.91, green: 0.20, blue: 0.45)
private let igGradient = LinearGradient(
    colors: [Color(red: 0.98, green: 0.73, blue: 0.29), igPink, Color(red: 0.53, green: 0.23, blue: 0.85)],
    startPoint: .bottomLeading, endPoint: .topTrailing
)

@main
struct InstaTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        InstaTimerLiveActivity()
    }
}

/// Small Instagram-style badge used in the bubble.
private struct IGBadge: View {
    var size: CGFloat = 20
    var body: some View {
        Image(systemName: "camera")
            .font(.system(size: size * 0.55, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: size * 0.3).fill(igGradient))
    }
}

struct InstaTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: InstaTimerAttributes.self) { context in
            // Lock Screen / banner
            HStack(spacing: 14) {
                IGBadge(size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Instagram today")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(context.state.countingFrom, style: .timer)
                        .font(.title.bold().monospacedDigit())
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.75))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Long-press expanded view
                DynamicIslandExpandedRegion(.leading) {
                    IGBadge(size: 36).padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.countingFrom, style: .timer)
                        .font(.title2.bold().monospacedDigit())
                        .foregroundStyle(igPink)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Time on Instagram today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                IGBadge(size: 20)
            } compactTrailing: {
                // This is the always-visible "bubble" timer
                Text(context.state.countingFrom, style: .timer)
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(igPink)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 48)
            } minimal: {
                IGBadge(size: 18)
            }
            .keylineTint(igPink)
        }
    }
}
