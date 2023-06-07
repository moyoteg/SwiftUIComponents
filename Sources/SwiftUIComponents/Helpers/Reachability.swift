//
//  Reachability.swift
//  SwiftUtilities
//
//  Created by Moi Gutierrez on 7/3/22.
//

import Foundation
#if os(iOS)
import SystemConfiguration

import SwiftUtilities

public extension SwiftUtilities {
    
    class Reachability {
        
        public class Network: ObservableObject {
            
            @Published public private(set) var reachable: Bool = false
            
            private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com")
            
            public init() {
                self.reachable = updateConnectionStatus()
            }
            
            private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
                
                let isReachable = flags.contains(.reachable)
                
                let connectionRequired = flags.contains(.connectionRequired)
                
                let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
                
                let canConnectWithoutIntervention = canConnectAutomatically && !flags.contains(.interventionRequired)
                
                return isReachable && (!connectionRequired || canConnectWithoutIntervention)
            }
            
            public func updateConnectionStatus() -> Bool {
                
                var flags = SCNetworkReachabilityFlags()
                
                SCNetworkReachabilityGetFlags(reachability!, &flags)
                
                return isNetworkReachable(with: flags)
            }
        }
        
        public enum Status {
            case notReachable
            case reachableViaWWAN
            case reachableViaWiFi
        }
        
        public static var currentStatus: Status {
            
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return .notReachable
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return .notReachable
            }
            
            if flags.contains(.reachable) == false {
                // The target host is not reachable.
                return .notReachable
            }
            else if flags.contains(.isWWAN) == true {
                // WWAN connections are OK if the calling application is using the CFNetwork APIs.
                return .reachableViaWWAN
            }
            else if flags.contains(.connectionRequired) == false {
                // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
                return .reachableViaWiFi
            }
            else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
                // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
                return .reachableViaWiFi
            }
            else {
                return .notReachable
            }
        }
        
    }
}
#endif

//
//  NetworkReachability.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 7/3/22.
//

import SwiftUI

import SwiftUtilities

#if !os(watchOS)
public struct Reachability: View {
    
    public enum Transport {
        case wifi
        case cellular
        
        var connectedImage: Image {
            switch self {
            case .wifi: return Image("wifi")
            case .cellular: return Image("antenna.radiowaves.left.and.right")
            }
        }
        
        var disconnectedImage: Image {
            switch self {
            case .wifi: return Image("wifi.slash")
            case .cellular: return Image("antenna.radiowaves.left.and.right.slash")
            }
        }
        
        func connectedStatusImage(isConnected: Bool) -> Image {
            if isConnected {
                return connectedImage
            } else {
                return disconnectedImage
            }
        }
    }
    
    let networkReachability = SwiftUtilities.Reachability.Network()
    
    let transport: Transport?
    
    public var body: some View {
        switch transport {
        case .some(let transport):
            transport.connectedStatusImage(isConnected: networkReachability.reachable)
                .padding()
        case .none:
            switch SwiftUtilities.Reachability.currentStatus {
            case .notReachable:
                Image("antenna.radiowaves.left.and.right.slash")
            case .reachableViaWWAN:
                Transport.cellular.connectedStatusImage(isConnected: networkReachability.reachable)
                    .padding()
            case .reachableViaWiFi:
                Transport.wifi.connectedStatusImage(isConnected: networkReachability.reachable)
                    .padding()
            }
        }
    }
    
    public init(transport: Transport? = nil) {
        self.transport = transport
    }
}
#endif
