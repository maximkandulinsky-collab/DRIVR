import SwiftData
import SwiftUI

@main
@MainActor
struct DRIVRApp: App {
    private let modelContainer: ModelContainer
    @State private var state: AppState

    init() {
        let result = Self.makeModelContainer()
        modelContainer = result.container
        let appState = AppState(modelContext: result.container.mainContext)
        if result.isTemporary {
            appState.alertMessage = "DRIVR could not open its local database. This session is running with temporary storage; completed drives may not survive a relaunch."
        }
        _state = State(initialValue: appState)
    }

    var body: some Scene {
        WindowGroup {
            RootView(state: state)
        }
        .modelContainer(modelContainer)
    }

    private static func makeModelContainer() -> (container: ModelContainer, isTemporary: Bool) {
        do {
            let container = try ModelContainer(for: Vehicle.self, Trip.self, AppPreferences.self)
            return (container, false)
        } catch {
            NSLog("DRIVR persistent database error: %@", error.localizedDescription)
            do {
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try ModelContainer(
                    for: Vehicle.self,
                    Trip.self,
                    AppPreferences.self,
                    configurations: configuration
                )
                return (container, true)
            } catch {
                fatalError("DRIVR cannot initialize its local data model: \(error.localizedDescription)")
            }
        }
    }
}
