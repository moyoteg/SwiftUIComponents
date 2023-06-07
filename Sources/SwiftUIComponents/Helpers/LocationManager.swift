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
    
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var currentLocation: CLLocation?
    @Published public var locationHistory: [CLLocation] = []
    @Published public var heading: CLHeading?
    @Published public var rangingBeacons: [CLBeacon] = []
    @Published public var monitoringRegions: [CLRegion] = []
    @Published public var visitHistory: [CLVisit] = []
    
    @Published public var didStartMonitoringFor: CLRegion?
    @Published public var monitoringDidFailFor: CLRegion?
    @Published public var didDetermineState: CLRegionState?
    @Published public var didRange: [CLBeacon]?
    @Published public var didFailRangingFor: CLBeaconIdentityConstraint?
    @Published public var didPauseLocationUpdates: CLLocationManager?
    @Published public var didResumeLocationUpdates: CLLocationManager?
    
    public override init() {
        super.init()
        
        locationManager.delegate = self
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
        Logger.log("LocationManager: didChangeAuthorization - Authorization status changed: \(status.rawValue)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationHistory.append(location)
        Logger.log("LocationManager: didUpdateLocations - Updated location: \(location)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.log("LocationManager: didFailWithError - Location manager failed with error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
        Logger.log("LocationManager: didUpdateHeading - Updated heading: \(newHeading)")
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        rangingBeacons = beacons
        Logger.log("LocationManager: didRangeBeacons - Ranged beacons: \(beacons)")
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        Logger.log("LocationManager: rangingBeaconsDidFailFor - Ranging beacons failed with error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        monitoringRegions.append(region)
        Logger.log("LocationManager: didEnterRegion - Entered region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let index = monitoringRegions.firstIndex(of: region) {
            monitoringRegions.remove(at: index)
        }
        Logger.log("LocationManager: didExitRegion - Exited region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        visitHistory.append(visit)
        Logger.log("LocationManager: didVisit - Visited location: \(visit)")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        didStartMonitoringFor = region
        Logger.log("LocationManager: didStartMonitoringFor - Started monitoring for region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        monitoringDidFailFor = region
        Logger.log("LocationManager: monitoringDidFailFor - Monitoring for region failed with error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        didDetermineState = state
        Logger.log("LocationManager: didDetermineState - Determined state \(state) for region: \(region)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        didRange = beacons
        Logger.log("LocationManager: didRange - Ranged beacons with constraint: \(beacons)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        didFailRangingFor = beaconConstraint
        Logger.log("LocationManager: didFailRangingFor - Ranging beacons failed with constraint: \(beaconConstraint), error: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didPauseLocationUpdates locationUpdates: CLLocationManager) {
        didPauseLocationUpdates = locationUpdates
        Logger.log("LocationManager: didPauseLocationUpdates - Paused location updates")
    }
    
    public func locationManager(_ manager: CLLocationManager, didResumeLocationUpdates locationUpdates: CLLocationManager) {
        didResumeLocationUpdates = locationUpdates
        Logger.log("LocationManager: didResumeLocationUpdates - Resumed location updates")
    }
}

