import SwiftUI
import Combine

public struct DrivrTheme {
    public static let secondaryText = Color.gray
    public static let primaryText = Color.white
    public static let accent = Color.blue
    public static let background = Color.black
    public static let lime = Color.green
    public static let raceBlue = Color.blue
}

public enum UnitSystem: String, CaseIterable, Identifiable, Hashable {
    case metric = "Metric"
    case imperial = "Imperial"
    
    public var id: String { self.rawValue }
    public var title: String { self.rawValue }
}

public class AppState: ObservableObject {
    @Published public var isDriveActive: Bool = false
    public init() {}
}

public class VehicleSetupViewModel: ObservableObject {
    @Published public var units: UnitSystem = .metric
    @Published public var errorMessage: String? = nil
    
    public init(vehicle: Any? = nil, units: UnitSystem = .metric, state: Any? = nil) {
        self.units = units
    }
}

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