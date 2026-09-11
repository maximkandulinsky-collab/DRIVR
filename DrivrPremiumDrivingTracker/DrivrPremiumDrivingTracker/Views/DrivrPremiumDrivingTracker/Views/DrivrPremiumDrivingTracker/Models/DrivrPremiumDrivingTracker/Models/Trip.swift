import Foundation
import SwiftData

enum TripSyncStatus: String, Codable, Sendable {
    case pending
    case syncing
    case synced
    case failed
}

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var vehicleID: UUID
    var startedAt: Date
    var endedAt: Date
    var durationSeconds: TimeInterval
    var distanceMeters: Double
    var averageSpeedMetersPerSecond: Double
    var topSpeedMetersPerSecond: Double
    var brakingScore: Int
    var accelerationScore: Int
    var corneringScore: Int
    var consistencyScore: Int
    var performanceScore: Int
    var overallScore: Int
    var eventCount: Int
    var hasRecoveryGap: Bool = false
    var syncStatusRaw: String
    var createdAt: Date
    @Attribute(.externalStorage) var routeData: Data
    @Attribute(.externalStorage) var eventData: Data

    init(
        id: UUID,
        vehicleID: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: TimeInterval,
        distanceMeters: Double,
        averageSpeedMetersPerSecond: Double,
        topSpeedMetersPerSecond: Double,
        scores: TripScores,
        eventCount: Int,
        hasRecoveryGap: Bool,
        routeData: Data,
        eventData: Data
    ) {
        self.id = id
        self.vehicleID = vehicleID
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = max(0, durationSeconds)
        self.distanceMeters = max(0, distanceMeters)
        self.averageSpeedMetersPerSecond = max(0, averageSpeedMetersPerSecond)
        self.topSpeedMetersPerSecond = max(0, topSpeedMetersPerSecond)
        brakingScore = scores.braking
        accelerationScore = scores.acceleration
        corneringScore = scores.cornering
        consistencyScore = scores.consistency
        performanceScore = scores.performance
        overallScore = scores.overall
        self.eventCount = max(0, eventCount)
        self.hasRecoveryGap = hasRecoveryGap
        syncStatusRaw = TripSyncStatus.pending.rawValue
        createdAt = .now
        self.routeData = routeData
        self.eventData = eventData
    }

    var syncStatus: TripSyncStatus {
        get { TripSyncStatus(rawValue: syncStatusRaw) ?? .pending }
        set { syncStatusRaw = newValue.rawValue }
    }

    var route: [RoutePoint] { routeDecodeResult.points }
    var routeIsMalformed: Bool { routeDecodeResult.isMalformed }
    var events: [DrivingEvent] { VersionedEventPayload.decode(eventData) }

    private var routeDecodeResult: RouteDecodeResult {
        VersionedRoutePayload.decodeResult(routeData)
    }
}

struct TripScores: Codable, Equatable, Sendable {
    let braking: Int
    let acceleration: Int
    let cornering: Int
    let consistency: Int
    let performance: Int
    let overall: Int
}

struct TripDraft: Sendable {
    let id: UUID
    let vehicleID: UUID
    let startedAt: Date
    let endedAt: Date
    let durationSeconds: TimeInterval
    let distanceMeters: Double
    let averageSpeedMetersPerSecond: Double
    let topSpeedMetersPerSecond: Double
    let scores: TripScores
    let route: [RoutePoint]
    let events: [DrivingEvent]
    let hasRecoveryGap: Bool
}
