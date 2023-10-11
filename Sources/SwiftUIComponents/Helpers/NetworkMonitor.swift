//
//  NetworkMonitor.swift
//
//
//  Created by Moi Gutierrez on 9/12/23.
//

import Foundation

import Network

public class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    
    @Published public var isConnected: Bool = true
    
    public init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "NetworkMonitoring")
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        
        monitor.start(queue: queue)
    }
}
