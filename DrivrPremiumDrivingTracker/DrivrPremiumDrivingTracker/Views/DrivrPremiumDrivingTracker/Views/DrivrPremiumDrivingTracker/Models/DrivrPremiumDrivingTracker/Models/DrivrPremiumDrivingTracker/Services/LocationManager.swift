@preconcurrency import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class LocationManager: NSObject, @preconcurrency CLLocationManagerDelegate {
    enum Availability: Equatable {
        case ready
        case servicesDisabled
        case denied
        case restricted
        case waitingForAuthorization
        case error(String)

        var message: String {
            switch self {
            case .ready: "Location ready"
            case .servicesDisabled: "Location Services are turned off"
            case .denied: "Location access is denied"
            case .restricted: "Location access is restricted on this iPhone"
            case .waitingForAuthorization: "Location permission is needed"
            case .error(let message): message
            }
        }
    }

    private let manager = CLLocationManager()
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var availability: Availability = .waitingForAuthorization
    private(set) var isTracking = false
    var onLocations: (([CLLocation]) -> Void)?

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.distanceFilter = 5
        refreshAvailability()
    }

    var canTrack: Bool {
        CLLocationManager.locationServicesEnabled()
            && (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways)
    }

    var canRequestWhenInUse: Bool { authorizationStatus == .notDetermined }
    var canEscalateToAlways: Bool { authorizationStatus == .authorizedWhenInUse }

    func requestWhenInUse() {
        guard CLLocationManager.locationServicesEnabled() else {
            availability = .servicesDisabled
            return
        }
        manager.requestWhenInUseAuthorization()
    }

    func requestBackgroundContinuity() {
        guard authorizationStatus == .authorizedWhenInUse else { return }
        manager.requestAlwaysAuthorization()
    }

    @discardableResult
    func startTracking() -> Bool {
        refreshAvailability()
        guard canTrack else { return false }
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
        if Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") != nil {
            manager.allowsBackgroundLocationUpdates = true
        }
        isTracking = true
        availability = .ready
        manager.startUpdatingLocation()
        return true
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        manager.showsBackgroundLocationIndicator = false
        manager.pausesLocationUpdatesAutomatically = true
        isTracking = false
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        refreshAvailability()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        availability = .ready
        onLocations?(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = error as? CLError
        if locationError?.code == .denied {
            refreshAvailability()
        } else if locationError?.code != .locationUnknown {
            availability = .error("GPS reported an error. DRIVR will keep trying while this drive is active.")
        }
    }

    private func refreshAvailability() {
        guard CLLocationManager.locationServicesEnabled() else {
            availability = .servicesDisabled
            return
        }
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            availability = .ready
        case .denied:
            availability = .denied
        case .restricted:
            availability = .restricted
        case .notDetermined:
            availability = .waitingForAuthorization
        @unknown default:
            availability = .waitingForAuthorization
        }
    }
}
