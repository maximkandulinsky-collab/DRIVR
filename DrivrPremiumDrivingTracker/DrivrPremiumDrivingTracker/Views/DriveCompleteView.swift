import SwiftUI

struct DriveCompleteView: View {
    @Bindable var state: AppState
    let trip: Trip

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                ScoreGauge(score: trip.overallScore, size: 190)
                RouteMapView(points: trip.route, height: 280)
                primaryMetrics
                scoreBreakdown
                localStatus
                doneButton
            }
            .padding(18)
            .padding(.bottom, 24)
        }
        .drivrBackground()
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("DRIVE COMPLETE")
                .font(.caption.weight(.black))
                .tracking(2)
                .foregroundStyle(DrivrTheme.lime)
            Text(state.activeVehicle?.nickname ?? "Saved drive")
                .font(.largeTitle.weight(.black))
            Text(DriveFormatter.date(trip.startedAt))
                .font(.subheadline)
                .foregroundStyle(DrivrTheme.secondaryText)
        }
        .padding(.top, 8)
    }

    private var primaryMetrics: some View {
        let distance = DriveFormatter.distance(meters: trip.distanceMeters, units: state.units)
        let average = DriveFormatter.speed(metersPerSecond: trip.averageSpeedMetersPerSecond, units: state.units)
        let maximum = DriveFormatter.speed(metersPerSecond: trip.topSpeedMetersPerSecond, units: state.units)
        return LazyVGrid(columns: columns, spacing: 10) {
            MetricTile(title: "Distance", value: distance.value, unit: distance.unit, tint: DrivrTheme.lime)
            MetricTile(title: "Duration", value: DriveFormatter.duration(trip.durationSeconds))
            MetricTile(title: "Average", value: average.value, unit: average.unit)
            MetricTile(title: "Maximum", value: maximum.value, unit: maximum.unit)
        }
        .drivrCard()
    }

    private var scoreBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SCORE BREAKDOWN")
                .font(.caption.weight(.black))
                .tracking(1.3)
                .foregroundStyle(DrivrTheme.secondaryText)
            LazyVGrid(columns: columns, spacing: 10) {
                ScoreResultTile(title: "Braking", score: trip.brakingScore)
                ScoreResultTile(title: "Acceleration", score: trip.accelerationScore)
                ScoreResultTile(title: "Cornering", score: trip.corneringScore)
                ScoreResultTile(title: "Performance", score: trip.performanceScore, tint: DrivrTheme.raceBlue)
            }
        }
        .drivrCard()
    }

    private var localStatus: some View {
        Label("Saved securely on this iPhone", systemImage: "checkmark.shield.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(DrivrTheme.lime)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(DrivrTheme.lime.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private var doneButton: some View {
        Button("DONE") { state.closeTrip() }
            .buttonStyle(PrimaryButtonStyle())
    }
}

private struct ScoreResultTile: View {
    let title: String
    let score: Int
    var tint = DrivrTheme.lime

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(DrivrTheme.secondaryText)
            Text("\(score)")
                .font(.system(.title, design: .rounded, weight: .black))
                .monospacedDigit()
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(score) out of 100")
    }
}