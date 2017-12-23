//
//  CloudServices.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable syntactic_sugar
import Foundation

final class CloudServices: ProcessCmd {
    override init (command: String?, arguments: Array<String>?) {
        super.init(command: command, arguments: arguments)
        self.updateDelegate = nil
    }
}
