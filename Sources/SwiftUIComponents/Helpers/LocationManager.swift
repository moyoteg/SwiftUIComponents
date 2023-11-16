//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 3/26/20.
//

import SwiftUI
import CoreLocation

import CloudyLogs

public class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
        
    // Authorization
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // Location
    @Published public var currentLocation: CLLocation?
    @Published public var currentLocationCoordinate2D: CLLocationCoordinate2D?
    @Published public var locationHistory: [CLLocation] = []
    
    // Heading
    @Published public var heading: CLHeading?
    
    // Beacons
    @Published public var rangingBeacons: [CLBeacon] = []
    
    // Regions
    @Published public var monitoringRegions: [CLRegion] = []
    @Published public var enteredRegion: CLRegion?
    @Published public var exitedRegion: CLRegion?
    
    // Visits
    @Published public var visitHistory: [CLVisit] = []
    
    // Errors
    @Published public var locationError: Error?
    @Published public var beaconRangingError: Error?
    @Published public var regionMonitoringError: Error?
    
    // properties for the delegate methods
    @Published public var didStartMonitoringFor: CLRegion?
    @Published public var didDetermineState: CLRegionState?
    @Published public var didRange: [CLBeacon] = []
    @Published public var didFailRangingFor: CLBeaconIdentityConstraint?
    @Published public var didPauseLocationUpdates: CLLocationManager?
    @Published public var didResumeLocationUpdates: CLLocationManager?

    public enum Update {
        case didInit
        case didChangeAuthorization(CLAuthorizationStatus)
        case didUpdateLocations([CLLocation])
        case didFailWithError(Error)
        case didUpdateHeading(CLHeading)
        case didRangeBeacons([CLBeacon], CLBeaconRegion)
        case rangingBeaconsDidFailFor(CLBeaconRegion, Error)
        case didEnterRegion(CLRegion)
        case didExitRegion(CLRegion)
        case didVisit(CLVisit)
        case monitoringDidFailFor(CLRegion?, Error)
        case didStartMonitoringFor(CLRegion)
        case didDetermineState(CLRegionState, CLRegion)
        case didRangeSatisfying([CLBeacon], CLBeaconIdentityConstraint)
        case didFailRangingFor(CLBeaconIdentityConstraint, Error)
        case didPauseLocationUpdates
        case didResumeLocationUpdates
    }
    
    @Published public var update: Update = .didInit

    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    public func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func startUpdatingHeading() {
        locationManager.startUpdatingHeading()
    }
    
    public func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    public func startRangingBeacons(in region: CLBeaconRegion) {
        locationManager.startRangingBeacons(satisfying: region.beaconIdentityConstraint)
    }
    
    public func stopRangingBeacons(in region: CLBeaconRegion) {
        locationManager.stopRangingBeacons(satisfying: region.beaconIdentityConstraint)
    }
    
    public func startMonitoring(for region: CLRegion) {
        locationManager.startMonitoring(for: region)
    }
    
    public func stopMonitoring(for region: CLRegion) {
        locationManager.stopMonitoring(for: region)
    }
    
    public func startMonitoringVisits() {
        locationManager.startMonitoringVisits()
    }
    
    public func stopMonitoringVisits() {
        locationManager.stopMonitoringVisits()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        update = .didChangeAuthorization(status)
        Logger.log("LocationManager: didChangeAuthorization - Authorization status changed: \(status.rawValue)")
        if status == .denied || status == .restricted {
            // Handle the case where user denies or restricts access
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        currentLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if locationHistory.count > 1000 { // Prevent indefinite growth
            locationHistory.removeFirst()
        }
        locationHistory.append(location)
        update = .didUpdateLocations(locations)
        Logger.log("LocationManager: didUpdateLocations - Updated location: \(location)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        update = .didFailWithError(error)
        Logger.log("LocationManager: didFailWithError - Location manager failed with error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
        update = .didUpdateHeading(newHeading)
        Logger.log("LocationManager: didUpdateHeading - Updated heading: \(newHeading)")
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        let condition = true
        return condition
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        rangingBeacons = beacons
        update = .didRangeBeacons(beacons, region)
        Logger.log("LocationManager: didRangeBeacons - Ranged beacons: \(beacons)")
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        beaconRangingError = error
        update = .rangingBeaconsDidFailFor(region, error)
        Logger.log("LocationManager: rangingBeaconsDidFailFor - Ranging beacons failed with error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        monitoringRegions.append(region)
        update = .didEnterRegion(region)
        Logger.log("LocationManager: didEnterRegion - Entered region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let index = monitoringRegions.firstIndex(of: region) {
            monitoringRegions.remove(at: index)
        }
        update = .didExitRegion(region)
        Logger.log("LocationManager: didExitRegion - Exited region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        visitHistory.append(visit)
        update = .didVisit(visit)
        Logger.log("LocationManager: didVisit - Visited location: \(visit)")
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        regionMonitoringError = error
        update = .monitoringDidFailFor(region, error)
        Logger.log("LocationManager: monitoringDidFailFor - Monitoring for region failed with error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        didStartMonitoringFor = region
        update = .didStartMonitoringFor(region)
        Logger.log("LocationManager: didStartMonitoringFor - Started monitoring for region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        didDetermineState = state
        update = .didDetermineState(state, region)
        Logger.log("LocationManager: didDetermineState - Determined state \(state) for region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        didRange = beacons
        update = .didRangeSatisfying(beacons, beaconConstraint)
        Logger.log("LocationManager: didRange - Ranged beacons with constraint: \(beacons)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        didFailRangingFor = beaconConstraint
        update = .didFailRangingFor(beaconConstraint, error)
        Logger.log("LocationManager: didFailRangingFor - Ranging beacons failed with constraint: \(beaconConstraint), error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didPauseLocationUpdates locationUpdates: CLLocationManager) {
        didPauseLocationUpdates = locationUpdates
        update = .didPauseLocationUpdates
        Logger.log("LocationManager: didPauseLocationUpdates - Paused location updates")
    }
    
    public func locationManager(_ manager: CLLocationManager, didResumeLocationUpdates locationUpdates: CLLocationManager) {
        didResumeLocationUpdates = locationUpdates
        update = .didResumeLocationUpdates
        Logger.log("LocationManager: didResumeLocationUpdates - Resumed location updates")
    }

}

