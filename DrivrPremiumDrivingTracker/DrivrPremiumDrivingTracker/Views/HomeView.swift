import SwiftUI

struct HomeView: View {
    @Bindable var state: AppState
    @State private var editingVehicle = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                if let vehicle = state.activeVehicle {
                    VehicleCard(vehicle: vehicle) { editingVehicle = true }
                }
                scoreSummary
                routePreview
                startButton
                recentDrives
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .drivrBackground()
        .sheet(isPresented: $editingVehicle) {
            if let vehicle = state.activeVehicle {
                VehicleSetupView(state: state, vehicle: vehicle) { editingVehicle = false }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DRIVR")
                    .font(.largeTitle.weight(.black))
                    .tracking(2)
                Text("LOCAL DRIVE INTELLIGENCE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(DrivrTheme.lime)
            }
            Spacer()
            Image(systemName: "location.north.circle.fill")
                .font(.title)
                .foregroundStyle(DrivrTheme.raceBlue)
        }
        .padding(.top, 12)
    }

    private var scoreSummary: some View {
        HStack(spacing: 22) {
            ScoreGauge(score: state.summary.averageOverallScore, size: 138)
            VStack(spacing: 18) {
                MetricTile(title: "Drives", value: "\(state.summary.tripCount)")
                let distance = DriveFormatter.distance(meters: state.summary.totalDistanceMeters, units: state.units)
                MetricTile(title: "Distance", value: distance.value, unit: distance.unit)
                MetricTile(title: "Drive time", value: DriveFormatter.duration(state.summary.totalDurationSeconds))
            }
        }
        .drivrCard()
    }

    @ViewBuilder
    private var routePreview: some View {
        if let latest = state.recentTrips.first {
            VStack(alignment: .leading, spacing: 12) {
                Text("LATEST ROUTE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(DrivrTheme.secondaryText)
                RouteMapView(points: latest.route, height: 190)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Label("READY FOR YOUR FIRST ROUTE", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(DrivrTheme.raceBlue)
                Text("Start a drive to build your local score and route history from real sensor data.")
                    .font(.subheadline)
                    .foregroundStyle(DrivrTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .drivrCard()
        }
    }

    private var startButton: some View {
        Button("START DRIVE") { state.prepareDrive() }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityHint("Opens sensor permission information before recording")
    }

    private var recentDrives: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !state.recentTrips.isEmpty {
                Text("RECENT DRIVES")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(DrivrTheme.secondaryText)
                ForEach(state.recentTrips.prefix(4)) { trip in
                    Button { state.openTrip(trip) } label: {
                        RecentTripRow(trip: trip, units: state.units)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct RecentTripRow: View {
    let trip: Trip
    let units: UnitSystem

    var body: some View {
        let distance = DriveFormatter.distance(meters: trip.distanceMeters, units: units)
        HStack(spacing: 14) {
            Image(systemName: "road.lanes")
                .foregroundStyle(DrivrTheme.raceBlue)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(DriveFormatter.date(trip.startedAt))
                    .font(.subheadline.weight(.semibold))
                Text("\(distance.joined) • \(DriveFormatter.duration(trip.durationSeconds))")
                    .font(.caption)
                    .foregroundStyle(DrivrTheme.secondaryText)
            }
            Spacer()
            Text("\(trip.overallScore)")
                .font(.title2.weight(.black).monospacedDigit())
                .foregroundStyle(DrivrTheme.lime)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(DrivrTheme.secondaryText)
        }
        .drivrCard()
    }