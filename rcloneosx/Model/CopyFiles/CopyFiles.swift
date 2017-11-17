//
//  CopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

final class CopyFiles: SetConfigurations {

    private var index: Int?
    private var config: Configuration?
    private var files: Array<String>?
    private var arguments: Array<String>?
    private var command: String?
    var argumentsObject: CopyFileArguments?
    private var argumentsRsync: Array<String>?
    private var argymentsRsyncDrynRun: Array<String>?
    private var commandDisplay: String?
    weak var progressDelegate: StartStopProgressIndicator?
    var process: CommandCopyFiles?
    var outputprocess: OutputProcess?

    func getOutput() -> Array<String> {
        return self.outputprocess?.getOutput() ?? [""]
    }

    func abort() {
        guard self.process != nil else { return }
        self.process!.abortProcess()
    }

    func executeRsync(remotefile: String, localCatalog: String, dryrun: Bool) {
        guard self.config != nil else { return }
        if dryrun {
            self.argumentsObject = CopyFileArguments(task: .cprclone, config: self.config!)
            self.arguments = self.argumentsObject!.getArguments()
        } else {
            self.argumentsObject = CopyFileArguments(task: .cprclone, config: self.config!)
            self.arguments = self.argumentsObject!.getArguments()
        }
        self.command = nil
        self.outputprocess = nil
        self.outputprocess = OutputProcess()
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }

    func getCommandDisplayinView(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else { return "" }
        guard self.index != nil else { return "" }
        let arguments = self.configurations?.arguments4rsync(index: self.index!, argtype: .arglistfiles)
        self.commandDisplay = Tools().rsyncpath() + " "
        for i in 0 ..< arguments!.count {
            self.commandDisplay! += arguments![i] + " "
        }
        guard self.commandDisplay != nil else { return "" }
        return self.commandDisplay!
    }

    private func getRemoteFileList() {
        self.outputprocess = nil
        self.outputprocess = OutputProcess()
        self.argumentsObject = CopyFileArguments(task: .lsrclone, config: self.config!)
        self.arguments = self.argumentsObject!.getArguments()
        self.command = self.argumentsObject!.getCommand()
        self.process = CommandCopyFiles(command: self.command, arguments: self.arguments)
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }

    func setRemoteFileList() {
        self.files = self.outputprocess?.trimoutput(trim: .one)
    }

    func filter(search: String?) -> Array<String> {
        guard search != nil else {
            if self.files != nil {
                return self.files!
            } else {
              return [""]
            }
        }
        if search!.isEmpty == false {
            return self.files!.filter({$0.contains(search!)})
        } else {
            return self.files!
        }
    }

    init (index: Int) {
        self.index = index
        self.config = self.configurations!.getConfigurations()[self.index!]
        self.getRemoteFileList()
    }

  }