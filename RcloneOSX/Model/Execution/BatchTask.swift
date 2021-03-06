//
//  newBatchTask.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 21.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

final class BatchTask: SetSchedules, SetConfigurations {

    weak var closeviewerrorDelegate: CloseViewError?
    var process: Process?
    var outputprocess: OutputProcess?
    var hiddenID: Int?
    var estimatedlist: [NSMutableDictionary]?

    func executeBatch() {
        self.estimatedlist = self.configurations?.estimatedlist
        if let batchobject = self.configurations!.getbatchQueue() {
            let work = batchobject.copyofnexttaskinqueue()
            switch work.1 {
            case 1:
                let index: Int = self.configurations!.getIndex(work.0)
                let config = self.configurations!.getConfigurations()[index]
                self.hiddenID = config.hiddenID
                self.outputprocess = OutputProcess()
                let arguments: [String] = self.configurations!.arguments4rclone(index: index, argtype: .arg)
                let process = Rclone(arguments: arguments)
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
            case -1:
                weak var localupdateprogressDelegate: StartStopProgressIndicator?
                localupdateprogressDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
                localupdateprogressDelegate?.complete()
                self.configurationsDelegate?.reloadconfigurationsobject()
            default :
                break
            }
        }
    }

    func closeOperation() {
        self.process?.terminate()
        self.process = nil
        self.configurations?.estimatedlist = nil
        self.configurations!.remoteinfotaskworkqueue = nil
    }

    func error() {
        self.closeviewerrorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
        self.closeviewerrorDelegate?.closeerror()
    }

    func processTermination() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch
        localprocessupdateDelegate?.processTermination()
        if let batchobject = self.configurations!.getbatchQueue() {
            let work = batchobject.removenexttaskinqueue()
            let index = self.configurations!.getIndex(work.0)
            let config = self.configurations!.getConfigurations()[index]
            self.hiddenID = config.hiddenID
            self.configurations!.setCurrentDateonConfiguration(index: index, outputprocess: self.outputprocess)
            self.executeBatch()
        }
    }

    func incount() -> Int {
        return self.outputprocess?.getOutput()?.count ?? 0
    }

    func maxcountintask(hiddenID: Int) -> Int {
        let max = self.configurations?.estimatedlist?.filter({$0.value( forKey: "hiddenID") as? Int == hiddenID})
        guard max!.count > 0 else { return 0}
        let maxnumber = max![0].value(forKey: "transferredNumber") as? String ?? "0"
        return Int(maxnumber) ?? 0
    }

    init() {
    }

}
