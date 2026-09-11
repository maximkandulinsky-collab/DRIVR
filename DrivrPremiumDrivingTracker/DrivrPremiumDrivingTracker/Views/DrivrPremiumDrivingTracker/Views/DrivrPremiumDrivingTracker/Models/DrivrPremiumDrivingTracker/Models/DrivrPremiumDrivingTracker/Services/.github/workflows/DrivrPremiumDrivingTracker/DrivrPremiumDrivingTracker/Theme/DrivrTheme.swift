import SwiftUI
import Combine

// MARK: - Missing Types / Structs
public struct RoutePoint: Identifiable, Hashable {
    public var id = UUID()
    public init() {}
}

public struct DrivingEvent: Identifiable, Hashable {
    public var id = UUID()
    public static func decode(_ data: Any?) -> [DrivingEvent] { [] }
    public init() {}
}

public struct RouteDecodeResult {
    public var points: [RoutePoint] = []
    public init() {}
}

public enum GPSQuality: String {
    case good = "Good"
    case poor = "Poor"
    public var rawValue: String { "Good" }
}

public class GPSTracker: ObservableObject {
    @Published public var gpsQuality: GPSQuality = .good
    public init() {}
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
    public init() {}
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

// MARK: - Formatters & Styles
public struct DriveFormatter {
    public static func distance(meters: Double, units: UnitSystem) -> (joined: String, value: String, unit: String) {
        return ("0 km", "0", "km")
    }
    public static func date(_ date: Date) -> String {
        return "Today"
    }
    public static func duration(_ seconds: Double) -> String {
        return "0 min"
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