//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.

import Foundation
import Cocoa

enum ViewController {
    case vctabmain
    case vcloggdata
    case vcnewconfigurations
    case vctabschedule
    case vcabout
    case vcbatch
    case vcprogressview
    case vccopyfiles
}

class ViewControllerReference {

    // Creates a singelton of this class
    class var  shared: ViewControllerReference {
        struct Singleton {
            static let instance = ViewControllerReference()
        }
        return Singleton.instance
    }

    // Temporary storage of the first scheduled task
    var scheduledTask: NSDictionary?
    // Download URL if new version is avaliable
    var URLnewVersion: String?
    // True if version 3.2.1 of rsync in /usr/local/bin
    var rsyncVer3: Bool = true
    // Optional path to rsync
    var rsyncPath: String?
    // No valid rsyncPath - true if no valid rsync is found
    var norsync: Bool = false
    // Detailed logging
    var detailedlogging: Bool = true
    // Temporary path for restore
    var restorePath: String?
    // Kind of Operation method. eiher Timer or DispatchWork
    var operation: OperationObject = .dispatch
    // Reference to the Operation object
    // Reference is set in when Scheduled task is executed
    var completeoperation: CompleteScheduledOperation?
    // rclone command
    var rsync: String = "rclone"
    var usrbinrsync: String = "/usr/bin/rclone"
    var usrlocalbinrsync: String = "/usr/local/bin/rclone"
    var configpath: String = "/Rclone/"
    // Loggfile
    var minimumlogging: Bool = false
    var fulllogging: Bool = false
    var logname: String = "rclonelog"
    var fileURL: URL?
    // Mark number of days since last backup
    var marknumberofdayssince: Double = 5

    // Reference to main View
    private var viewControllertabMain: NSViewController?
    // Reference to Copy files
    private var viewControllerCopyFiles: NSViewController?
    // Reference to the New tasks
    private var viewControllerNewConfigurations: NSViewController?
    // Reference to the  Schedule
    private var viewControllertabSchedule: NSViewController?
    // Which profile to use, if default nil
    private var viewControllerLoggData: NSViewController?
    // Reference to Ssh view
    private var viewControllerSsh: NSViewController?
    // Reference to About
    private var viewControllerAbout: NSViewController?
    //  Refereence to batchview
    private var viewControllerBatch: NSViewController?
    // ProgressView single task
    private var viewControllerProgressView: NSViewController?

    func getvcref(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .vctabmain:
            return self.viewControllertabMain
        case .vcloggdata:
            return self.viewControllerLoggData
        case .vcnewconfigurations:
            return self.viewControllerNewConfigurations
        case .vctabschedule:
            return self.viewControllertabSchedule
        case .vcabout:
            return self.viewControllerAbout
        case .vcbatch:
            return self.viewControllerBatch
        case .vcprogressview:
            return self.viewControllerProgressView
        case .vccopyfiles:
            return self.viewControllerCopyFiles
        }
    }

    func setvcref(viewcontroller: ViewController, nsviewcontroller: NSViewController) {
        switch viewcontroller {
        case .vctabmain:
            self.viewControllertabMain = nsviewcontroller
        case .vcloggdata:
            self.viewControllerLoggData = nsviewcontroller
        case .vcnewconfigurations:
            self.viewControllerNewConfigurations = nsviewcontroller
        case .vctabschedule:
            self.viewControllertabSchedule = nsviewcontroller
        case .vcabout:
            self.viewControllerAbout = nsviewcontroller
        case .vcbatch:
            self.viewControllerBatch = nsviewcontroller
        case .vcprogressview:
            self.viewControllerProgressView = nsviewcontroller
        case .vccopyfiles:
            self.viewControllerCopyFiles = nsviewcontroller
        }
    }
}
