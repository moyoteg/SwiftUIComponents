//
//  NetworkMonitor.swift
//
//
//  Created by Moi Gutierrez on 9/12/23.
//

import Foundation
import Network

import CloudyLogs

public class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    
    @Published public var isConnected: Bool = true
    
    public init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "NetworkMonitoring")
        
        monitor.pathUpdateHandler = { [weak self] path in
            
            if path.isConstrained {
                Logger.log("NetworkMonitor: isConstrained: \(path.isConstrained)")
            }
            
            if path.isExpensive {
                Logger.log("NetworkMonitor: isExpensive: \(path.isExpensive)")
            }
            
            if path.supportsDNS {
                Logger.log("NetworkMonitor: supportsDNS: \(path.supportsDNS)")
            }
            
            if path.supportsIPv4 {
                Logger.log("NetworkMonitor: supportsIPv4: \(path.supportsIPv4)")
            }
            
            if path.supportsIPv6 {
                Logger.log("NetworkMonitor: supportsIPv6: \(path.supportsIPv6)")
            }
            
            if let localEndpoint = path.localEndpoint {
                Logger.log("NetworkMonitor: localEndpoint: \(localEndpoint)")
            }
            
            if let remoteEndpoint = path.remoteEndpoint {
                Logger.log("NetworkMonitor: remoteEndpoint: \(remoteEndpoint)")
            }
            
            Logger.log("NetworkMonitor: unsatisfiedReason: \(path.unsatisfiedReason)")
            Logger.log("NetworkMonitor: status: \(path.status)")
            Logger.log("NetworkMonitor: availableInterfaces: \(path.availableInterfaces)")
            Logger.log("NetworkMonitor: gateways: \(path.gateways)")
            
            if path.usesInterfaceType(.wifi) {
                Logger.log("NetworkMonitor: wifi")
            } else if path.usesInterfaceType(.cellular) {
                Logger.log("NetworkMonitor: cellular")
            }
            
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        
        monitor.start(queue: queue)
    }
}
