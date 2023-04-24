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
            case .wifi: return Image(systemName: "wifi")
            case .cellular: return Image(systemName: "antenna.radiowaves.left.and.right")
            }
        }
        
        var disconnectedImage: Image {
            switch self {
            case .wifi: return Image(systemName: "wifi.slash")
            case .cellular: return Image(systemName: "antenna.radiowaves.left.and.right.slash")
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
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
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
