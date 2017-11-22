//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol OperationChanged: class {
    func operationsmethod()
}
class ViewControllerUserconfiguration: NSViewController, NewRsync, SetDismisser, Delay {

    var storageapi: PersistentStorageAPI?
    var dirty: Bool = false
    weak var operationchangeDelegate: OperationChanged?

    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var noRsync: NSTextField!
    @IBOutlet weak var operation: NSButton!
    @IBOutlet weak var restorePath: NSTextField!
    @IBOutlet weak var minimumlogging: NSButton!
    @IBOutlet weak var fulllogging: NSButton!
    @IBOutlet weak var nologging: NSButton!

    @IBAction func toggleDetailedlogging(_ sender: NSButton) {
        if self.detailedlogging.state == .on {
            ViewControllerReference.shared.detailedlogging = true
        } else {
            ViewControllerReference.shared.detailedlogging = false
        }
        self.dirty = true
    }

    @IBAction func close(_ sender: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.setRestorePath()
            _ = self.storageapi!.saveUserconfiguration()
        }
        if (self.presenting as? ViewControllertabMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllertabSchedule) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presenting as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
    }

    @IBAction func toggleOperation(_ sender: NSButton) {
        if self.operation.state == .on {
            ViewControllerReference.shared.operation = .dispatch
        } else {
            ViewControllerReference.shared.operation = .timer
        }
        self.operationchangeDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
        self.operationchangeDelegate?.operationsmethod()
        self.dirty = true
    }

    @IBAction func logging(_ sender: NSButton) {
        if self.fulllogging.state == .on {
            ViewControllerReference.shared.fulllogging = true
            ViewControllerReference.shared.minimumlogging = false
        } else if self.minimumlogging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = true
        } else if self.nologging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = false
        }
    }

    private func setRsyncPath() {
        if self.rsyncPath.stringValue.isEmpty == false {
            if rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncPath.stringValue += "/"
                ViewControllerReference.shared.rsyncPath = rsyncPath.stringValue
            }
        } else {
            ViewControllerReference.shared.rsyncPath = nil
        }
        self.dirty = true
    }

    private func verifyrsync() {
        let rsyncpath: String?
        let fileManager = FileManager.default
        if self.rsyncPath.stringValue.isEmpty == false {
            if self.rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncpath = self.rsyncPath.stringValue + "/" + ViewControllerReference.shared.rsync
            } else {
                rsyncpath = self.rsyncPath.stringValue + ViewControllerReference.shared.rsync
            }
        } else {
            rsyncpath = nil
        }
        guard rsyncpath != nil else {
            self.noRsync.isHidden = true
            ViewControllerReference.shared.norsync = false
            return
        }
        if fileManager.fileExists(atPath: rsyncpath!) {
            self.noRsync.isHidden = true
            ViewControllerReference.shared.norsync = false
        } else {
            self.noRsync.isHidden = false
            ViewControllerReference.shared.norsync = true
        }
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            } else {
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            }
        } else {
            ViewControllerReference.shared.restorePath = nil
        }
        self.dirty = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
        self.storageapi = PersistentStorageAPI(profile: nil)
        self.nologging.state = .on
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        self.checkUserConfig()
        self.verifyrsync()
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if ViewControllerReference.shared.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            self.rsyncPath.stringValue = ViewControllerReference.shared.rsyncPath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        if ViewControllerReference.shared.restorePath != nil {
            self.restorePath.stringValue = ViewControllerReference.shared.restorePath!
        } else {
            self.restorePath.stringValue = ""
        }
        switch ViewControllerReference.shared.operation {
        case .dispatch:
            self.operation.state = .on
        case .timer:
            self.operation.state = .off
        }
    }
}

extension ViewControllerUserconfiguration: NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.dirty = true
        delayWithSeconds(0.5) {
            self.verifyrsync()
            self.newrsync()
        }
    }
}
