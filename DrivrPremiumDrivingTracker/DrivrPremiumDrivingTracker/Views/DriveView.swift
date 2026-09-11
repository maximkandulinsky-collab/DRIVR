import SwiftUI

struct DriveView: View {
    @Bindable var state: AppState
    @State private var confirmingEnd = false
    @ScaledMetric(relativeTo: .largeTitle) private var speedSize = 104

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                driveHeader
                speedometer
                liveMetrics
                statusPanel
                RouteMapView(points: state.tracker.route, isLive: true, height: 300)
                endButton
            }
            .padding(18)
        }
        .scrollDisabled(true)
        .drivrBackground()
        .alert("End this drive?", isPresented: $confirmingEnd) {
            Button("Keep Driving", role: .cancel) {}
            Button("End and Save", role: .destructive) {
                Task { await state.endDrive() }
            }
        } message: {
            Text("Location and motion recording will stop immediately, then this drive will be finalized and saved on this iPhone.")
        }
    }

    private var driveHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("DRIVE ACTIVE")
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(DrivrTheme.lime)
                Text(state.activeVehicle?.nickname ?? "Active vehicle")
                    .font(.headline)
            }
            Spacer()
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                Text(DriveFormatter.duration(state.tracker.elapsedSeconds))
                    .font(.title3.bold().monospacedDigit())
                    .accessibilityLabel("Elapsed time")
            }
        }
    }

    private var speedometer: some View {
        let speed = DriveFormatter.speed(
            metersPerSecond: state.tracker.displayedSpeedMetersPerSecond,
            units: state.units
        )
        return VStack(spacing: -4) {
            Text(speed.value)
                .font(.system(size: min(speedSize, 130), weight: .black, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.55)
                .lineLimit(1)
            Text(speed.unit.uppercased())
                .font(.headline.weight(.black))
                .tracking(3)
                .foregroundStyle(DrivrTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current speed")
        .accessibilityValue(speed.joined)
    }

    private var liveMetrics: some View {
        let distance = DriveFormatter.distance(meters: state.tracker.distanceMeters, units: state.units)
        let topSpeed = DriveFormatter.speed(metersPerSecond: state.tracker.topSpeedMetersPerSecond, units: state.units)
        return HStack(spacing: 10) {
            MetricTile(title: "Distance", value: distance.value, unit: distance.unit, tint: DrivrTheme.lime)
            MetricTile(title: "Top speed", value: topSpeed.value, unit: topSpeed.unit)
            MetricTile(title: "Events", value: "\(state.tracker.events.count)")
        }
        .drivrCard()
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("GPS \(state.tracker.gpsQuality.rawValue)", systemImage: "location.fill")
                    .foregroundStyle(gpsColor)
                Spacer()
                Text(state.analysisStatus)
                    .foregroundStyle(DrivrTheme.secondaryText)
            }
            .font(.caption.weight(.bold))
            if state.tracker.hasRecoveryGap {
                Label("Recovered drive: time away may include a route gap", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            if case .error(let message) = state.locationManager.availability {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .drivrCard()
    }

    private var endButton: some View {
        Button(role: .destructive) { confirmingEnd = true } label: {
            Label("END DRIVE", systemImage: "stop.fill")
                .font(.headline.weight(.black))
                .tracking(1.2)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.red.opacity(0.18), in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18).stroke(Color.red.opacity(0.75), lineWidth: 1)
                }
        }
        .foregroundStyle(.red)
    }

    private var gpsColor: Color {
        switch state.tracker.gpsQuality {
        case .good: DrivrTheme.lime
        case .fair: DrivrTheme.raceBlue
        case .poor, .searching: .orange
        }
    }
}