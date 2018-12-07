//
//  OperationFactory.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Protocol for starting next scheduled job
protocol StartNextTask: class {
    // func startanyscheduledtask()
    func startfirstcheduledtask()
}

protocol NextTask {
    var nexttaskDelegate: StartNextTask? { get }
}

extension NextTask {
    weak var nexttaskDelegate: StartNextTask? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func startnexttask() {
        self.nexttaskDelegate?.startfirstcheduledtask()
    }
}

// Protocol when a Scehduled job is starting and stopping
// Used to informed the presenting viewcontroller about what
// is going on
protocol ScheduledTaskWorking: class {
    func start()
    func completed()
}

protocol SetScheduledTask {
    var scheduleJob: ScheduledTaskWorking? { get }
}

extension SetScheduledTask {
    weak var scheduleJob: ScheduledTaskWorking? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}

protocol GetsortedanexpandedObject: class {
    func getsortedanexpandedObject() -> ScheduleSortedAndExpand?
}

protocol SecondsBeforeStart {
    func secondsbeforestart() -> Double
}

extension SecondsBeforeStart {

    func secondsbeforestart() -> Double {
        var secondsToWait: Double?
        weak var schedulesDelegate: GetsortedanexpandedObject?
        schedulesDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        let scheduledJobs = schedulesDelegate?.getsortedanexpandedObject()
        if let dict = scheduledJobs?.firstscheduledtask() {
            let dateStart: Date = (dict.value(forKey: "start") as? Date)!
            secondsToWait = Dateandtime().timeDoubleSeconds(dateStart, enddate: nil)
        }
        return secondsToWait ?? 0
    }
}

enum OperationObject {
    case timer
    case dispatch
}

protocol Sendprocessreference: class {
    func sendprocessreference(process: Process?)
    func sendoutputprocessreference(outputprocess: OutputProcess?)
}

class OperationFactory {

    var operationTimer: ScheduleOperationTimer?
    var operationDispatch: ScheduleOperationDispatch?

    init(factory: OperationObject) {
        switch factory {
        case .timer:
            self.operationTimer = ScheduleOperationTimer()
        case .dispatch:
            self.operationDispatch = ScheduleOperationDispatch()
        }
    }

    init() {
        self.operationDispatch = ScheduleOperationDispatch(seconds: 0)
    }
}
