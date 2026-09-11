import SwiftUI

public struct DrivrTheme {
    public static let secondaryText = Color.gray
    public static let primaryText = Color.white
    public static let accent = Color.blue
    public static let background = Color.black
    public static let lime = Color.green
}

public enum UnitSystem: String, CaseIterable, Identifiable, Hashable {
    case metric = "Metric"
    case imperial = "Imperial"
    
    public var id: String { self.rawValue }
    public var title: String { self.rawValue }
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