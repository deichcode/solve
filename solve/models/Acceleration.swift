//
//  Acceleration.swift
//  Solve
//
//  Created by Marek Elznic on 22/01/2020.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import Foundation

/*
 * Struct that stores data about previous states of the accelerometer.
 */
struct Acceleration {
    var smooth:     (x: Double, y: Double, z: Double)
    var rolling:    (x: Double, y: Double, z: Double)
}
