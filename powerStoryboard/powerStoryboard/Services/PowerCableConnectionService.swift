//
//  PowerCableConnectionService.swift
//  powerStoryboard
//
//  Created by Sören Schröder on 11.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//
import UIKit

protocol PowerCableConnectionServiceProtocol {
    func register(connectCallback:  @escaping () -> ()) -> Void
    func register(disconnectCallback:  @escaping () -> ()) -> Void
}

class PowerCableConnectionService : PowerCableConnectionServiceProtocol {
    private var batteryState: UIDevice.BatteryState { UIDevice.current.batteryState }
    private var connectCallback : (() -> ())?
    private var disconnectCallback : (() -> ())?
    
    init() {
        connectCallback = nil
        disconnectCallback = nil
        enableBatteryMonitoring()
    }
    
    fileprivate func enableBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChangeCallback), name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    
    
    @objc private func batteryStateDidChangeCallback(_ notification: Notification) {
        propagateBatteryState()
    }
    
    private func propagateBatteryState() {
        switch batteryState {
        case .charging, .full:
            guard let callback = connectCallback else { return }
            callback()
        case .unplugged, .unknown:
            guard let callback = disconnectCallback else { return }
            callback()
        @unknown default:
            guard let callback = disconnectCallback else { return }
            callback()
        }
    }
    
    func register(connectCallback: @escaping () -> ()) {
        self.connectCallback = connectCallback
        propagateBatteryState()
    }
    
    func register(disconnectCallback: @escaping () -> ()) {
        self.disconnectCallback = disconnectCallback
        propagateBatteryState()
    }
}
