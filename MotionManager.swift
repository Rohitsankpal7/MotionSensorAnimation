//
//  MotionManager.swift
//  MotionSensorAnimation
//
//  Created by Rohit Sankpal on 02/01/25.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    private let motion = CMMotionManager()
    private let queue = OperationQueue()
    @Published var tilt: (x: Double, y: Double) = (0, 0)

    func startUpdates() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 0.03
        motion.startDeviceMotionUpdates(to: queue) { [weak self] data, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.tilt = (data.gravity.x, data.gravity.y)
            }
        }
    }

    func stopUpdates() {
        motion.stopDeviceMotionUpdates()
    }
}
