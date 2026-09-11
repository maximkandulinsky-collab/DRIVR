import SwiftUI
import Combine

// MARK: - Missing Types & Models
public struct RoutePoint: Identifiable, Hashable, Sendable {
    public var id = UUID()
    public init() {}
}

public struct DrivingEvent: Identifiable, Hashable, Sendable {
    public var id = UUID()
    public static func decode(_ data: Any?) -> [DrivingEvent] { [] }
    public init() {}
}

public struct RouteDecodeResult {
    public var points: [RoutePoint] = []
    public var isMalformed: Bool = false
    public init() {}
}

public struct VersionedEventPayload {
    public static func decode(_ data: Any?) -> [DrivingEvent] { [] }
}

public struct VersionedRoutePayload {
    public static func decodeResult(_ data: Any?) -> RouteDecodeResult { RouteDecodeResult() }
}

public enum GPSQuality: String {
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    public var rawValue: String { "Good" }
}

public class GPSTracker: ObservableObject {
    @Published public var gpsQuality: GPSQuality = .good
    @Published public var route: [RoutePoint] = []
    @Published public var displayedSpeedMetersPerSecond: Double = 0.0
    @Published public var distanceMeters: Double = 0.0
    @Published public var topSpeedMetersPerSecond: Double = 0.0
    @Published public var events: [DrivingEvent] = []
    public init() {}
}

public class VehicleItem: ObservableObject {
    @Published public var nickname: String = ""
    public init(nickname: String = "") {
        self.nickname = nickname
    }
}

// MARK: - Theme & Layout
public struct DrivrTheme {
    public static let secondaryText = Color.gray
    public static let primaryText = Color.white
    public static let accent = Color.blue
    public static let background = Color.black
    public static let lime = Color.green
    public static let raceBlue = Color.blue
    public static let elevated = Color.gray.opacity(0.15)
}

public enum UnitSystem: String, CaseIterable, Identifiable, Hashable {
    case metric = "Metric"
    case imperial = "Imperial"
    
    public var id: String { self.rawValue }
    public var title: String { self.rawValue }
    
    public var detail: String {
        switch self {
        case .metric: return "Kilometers, Liters"
        case .imperial: return "Miles, Gallons"
        }
    }
}

// MARK: - App State
public class AppState: ObservableObject {
    @Published public var isDriveActive: Bool = false
    @Published public var units: UnitSystem = .metric
    @Published public var tracker: GPSTracker = GPSTracker()
    @Published public var activeVehicle: VehicleItem? = VehicleItem()
    @Published public var analysisStatus: String = "Ready"
    
    public init() {}
    public func closeTrip() {}
}

// MARK: - View Model
public class VehicleSetupViewModel: ObservableObject {
    @Published public var title: String = "Vehicle Setup"
    @Published public var units: UnitSystem = .metric
    @Published public var errorMessage: String? = nil
    @Published public var canSave: Bool = true
    @Published public var make: String = ""
    @Published public var model: String = ""
    @Published public var year: String = ""
    @Published public var trim: String = ""
    @Published public var vin: String = ""
    @Published public var licensePlate: String = ""
    @Published public var engine: String = ""
    @Published public var nickname: String = ""
    @Published public var notes: String = ""
    @Published public var imageData: Data? = nil
    @Published public var isProcessingPhoto: Bool = false
    @Published public var editingVehicle: Any? = nil
    
    public init(vehicle: Any? = nil, units: UnitSystem = .metric, state: Any? = nil) {
        self.units = units
        self.editingVehicle = vehicle
    }
    
    public func save(into state: Any? = nil, onFinished: (() -> Void)? = nil) -> Bool {
        onFinished?()
        return true
    }
    
    public func loadPhoto(_ item: Any?) async {}
    public func processPhoto(_ image: Any? = nil) {}
    public func deleteVehicle(from state: Any? = nil) {}
}

// MARK: - Formatters & Views
public struct DriveFormatter {
    public static func distance(meters: Double, units: UnitSystem) -> (joined: String, value: String, unit: String) {
        return ("0 km", "0", "km")
    }
    public static func speed(metersPerSecond: Double, units: UnitSystem) -> (joined: String, value: String, unit: String) {
        return ("0 km/h", "0", "km/h")
    }
    public static func date(_ date: Date) -> String {
        return "Today"
    }
    public static func duration(_ seconds: Double) -> String {
        return "0 min"
    }
}

public struct MetricTile: View {
    let title: String
    let value: String
    var unit: String = ""
    var tint: Color = .white
    
    public init(title: String, value: String, unit: String = "", tint: Color = .white) {
        self.title = title
        self.value = value
        self.unit = unit
        self.tint = tint
    }
    
    public var body: some View {
        VStack {
            Text(title).font(.caption).foregroundColor(.gray)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value).font(.title2).bold().foregroundColor(tint)
                if !unit.isEmpty {
                    Text(unit).font(.caption).foregroundColor(.gray)
                }
            }
        }
    }
}

public struct RouteMapView: View {
    let points: [RoutePoint]
    let isLive: Bool
    let height: CGFloat
    
    public init(points: [RoutePoint], isLive: Bool = false, height: CGFloat = 200) {
        self.points = points
        self.isLive = isLive
        self.height = height
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: height)
            .cornerRadius(12)
    }
}

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension View {
    public func drivrCard() -> some View {
        self.padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
    }

    public func drivrBackground() -> some View {
        self.background(Color.black.ignoresSafeArea())
    }
}