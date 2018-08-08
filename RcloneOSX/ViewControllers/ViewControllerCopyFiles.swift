//
//  ViewControllerCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

protocol SetIndex: class {
    func setIndex(index: Int)
}

protocol GetSource: class {
    func getSource(index: Int)
}

class ViewControllerCopyFiles: NSViewController, SetConfigurations, GetIndex, Delay, VcCopyFiles {
    
    var copyFiles: CopyFiles?
    var index: Int?
    var indexselected: Int?
    var rsync: Bool = false
    var estimated: Bool = false
    private var tabledata: [String]?
    
    @IBOutlet weak var numberofrows: NSTextField!
    @IBOutlet weak var server: NSTextField!
    @IBOutlet weak var rcatalog: NSTextField!
    @IBOutlet weak var info: NSTextField!
    
    private func info(num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "No such local catalog..."
        case 2:
            self.info.stringValue = "Not a remote task, use Finder to copy files..."
        case 3:
            self.info.stringValue = "Local or remote catalog cannot be empty..."
        case 4:
            self.info.stringValue = "Got index from Execute, select Source for another index..."
        case 5:
            self.info.stringValue = "Please select a source..."
        default:
            self.info.stringValue = ""
        }
    }
    
    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.working.stopAnimation(nil)
        guard self.copyFiles != nil else { return }
        self.copyButton.isEnabled = true
        self.copyFiles!.abort()
    }
    
    @IBOutlet weak var tableViewSelect: NSTableView!
    @IBOutlet weak var commandString: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workingRclone: NSProgressIndicator!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var sourceButton: NSButton!
    
    // Do the work
    @IBAction func copy(_ sender: NSButton) {
        guard self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false else {
            self.info(num: 3)
            return
        }
        if self.copyFiles != nil {
            self.rsync = true
            self.workingRclone.startAnimation(nil)
            if self.estimated == false {
                self.copyFiles!.executeRclone(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: true)
                self.copyButton.title = "Execute"
                self.estimated = true
            } else {
                self.copyButton.isEnabled = false
                self.workingRclone.startAnimation(nil)
                self.copyFiles!.executeRclone(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
                self.estimated = false
            }
        }
    }
    
    // Getting index from Execute View
    @IBAction func getIndex(_ sender: NSButton) {
        self.copyFiles = nil
        if let index = self.index {
            self.copyFiles = CopyFiles(index: index)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: index)
        } else {
            self.info(num: 5)
        }
    }
    
    @IBAction func reset(_ sender: NSButton) {
        self.resetCopySource()
        self.presentViewControllerAsSheet(self.viewControllerSource!)
    }
    
    // Reset copy source
    private func resetCopySource() {
        if self.copyFiles != nil {
            self.copyFiles!.abort()
        }
        self.index = nil
        self.tabledata = nil
        self.copyFiles = nil
        self.info(num: 0)
        globalMainQueue.async(execute: { () -> Void in
            self.tableViewSelect.reloadData()
        })
        self.displayRemoteserver(index: nil)
        self.remoteCatalog.stringValue = ""
        self.commandString.stringValue = ""
        self.rsync = false
        self.copyButton.isEnabled = true
        self.sourceButton.isEnabled = true
    }
    
    private func displayRemoteserver(index: Int?) {
        guard index != nil else {
            self.server.stringValue = ""
            self.rcatalog.stringValue = ""
            return
        }
        let hiddenID = self.configurations!.gethiddenID(index: index!)
        globalMainQueue.async(execute: { () -> Void in
            self.server.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer)
            self.rcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .remoteCatalog)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vccopyfiles, nsviewcontroller: self)
        self.tableViewSelect.delegate = self
        self.tableViewSelect.dataSource = self
        self.working.usesThreadedAnimation = true
        self.workingRclone.usesThreadedAnimation = true
        self.search.delegate = self
        self.localCatalog.delegate = self
        self.tableViewSelect.doubleAction = #selector(self.tableViewDoubleClick(sender:))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.indexselected = self.index
        self.index = self.index()
        if let index = self.index {
            self.displayRemoteserver(index: index)
            self.info(num: 4)
            if self.indexselected != nil {
                if self.indexselected != self.index {
                    self.resetdata()
                }
            } else {
                self.resetdata()
            }
        } else {
            self.resetCopySource()
        }
        self.copyButton.isEnabled = true
        self.copyButton.title = "Estimate"
        if let restorePath = ViewControllerReference.shared.restorePath {
            self.localCatalog.stringValue = restorePath
        } else {
            self.localCatalog.stringValue = ""
        }
        self.verifylocalCatalog()
    }
    
    private func resetdata() {
        self.tabledata = nil
        self.copyFiles = nil
        self.remoteCatalog.stringValue = ""
        self.localCatalog.stringValue = ""
        self.commandString.stringValue = ""
        self.estimated = false
        self.rsync = false
        globalMainQueue.async(execute: { () -> Void in
            self.tableViewSelect.reloadData()
        })
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        guard self.index != nil else { return }
        guard self.remoteCatalog.stringValue.isEmpty == false else { return }
        guard self.localCatalog.stringValue.isEmpty == false else { return }
        let answer = Alerts.dialogOKCancel("Copy single files or directory", text: "Start copy?")
        if answer {
            self.copyButton.title = "Execute"
            self.copyButton.isEnabled = false
            self.rsync = true
            self.workingRclone.startAnimation(nil)
            self.copyFiles!.executeRclone(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
        }
    }
    
    private func verifylocalCatalog() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.localCatalog.stringValue) == false {
            self.info(num: 1)
        }
    }
}

extension ViewControllerCopyFiles: NSSearchFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        self.delayWithSeconds(0.25) {
            let filterstring = self.search.stringValue
            if filterstring.isEmpty {
                globalMainQueue.async(execute: { () -> Void in
                    self.tabledata = self.copyFiles?.filter(search: nil)
                    self.tableViewSelect.reloadData()
                })
            } else {
                globalMainQueue.async(execute: { () -> Void in
                    self.tabledata = self.copyFiles?.filter(search: filterstring)
                    self.tableViewSelect.reloadData()
                })
            }
        }
        self.verifylocalCatalog()
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles?.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
}

extension ViewControllerCopyFiles: NSTableViewDataSource {
    
    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        guard self.tabledata != nil else {
            self.numberofrows.stringValue = "Number of remote files:"
            return 0
        }
        self.numberofrows.stringValue = "Number of remote files: " + String(self.tabledata!.count)
        return self.tabledata!.count
    }
}

extension ViewControllerCopyFiles: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String?
        var cellIdentifier: String?
        guard self.tabledata != nil else {
            return nil
        }
        var split = self.tabledata![row].components(separatedBy: " ")
        if tableColumn == tableView.tableColumns[0] {
            let num = Double(split[0]) ?? 0
            text = NumberFormatter.localizedString(from: NSNumber(value: num), number: NumberFormatter.Style.decimal)
            cellIdentifier = "sizeID"
        }
        if tableColumn == tableView.tableColumns[1] {
            if split.count > 1 {
                text = split[1]
            } else {
                text = split[0]
            }
            cellIdentifier = "fileID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier!), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text!
            return cell
        } else {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            guard self.tabledata != nil else { return }
            let split = self.tabledata![index].components(separatedBy: " ")
            if split.count > 1 {
                self.remoteCatalog.stringValue = split[1]
            } else {
                self.remoteCatalog.stringValue = self.tabledata![index]
            }
            guard self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false else { return }
            self.commandString.stringValue = self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue)
            self.estimated = false
            self.copyButton.title = "Estimate"
        }
    }
}

extension ViewControllerCopyFiles: Reloadandrefresh {
    func reloadtabledata() {
        guard self.copyFiles != nil else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles!.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
}

extension ViewControllerCopyFiles: StartStopProgressIndicator {
    func stop() {
        self.working.stopAnimation(nil)
    }
    
    func start() {
        self.working.startAnimation(nil)
    }
    
    func complete() {
        // nothing
    }
}

extension ViewControllerCopyFiles: UpdateProgress {
    func processTermination() {
        if self.rsync == false {
            self.copyFiles!.setRemoteFileList()
            self.reloadtabledata()
            self.stop()
        } else {
            self.workingRclone.stopAnimation(nil)
            self.presentViewControllerAsSheet(self.viewControllerInformation!)
        }
    }
    
    func fileHandler() {
        // nothing
    }
}

extension ViewControllerCopyFiles: Information {
    func getInformation() -> [String] {
        return self.copyFiles!.getOutput()
    }
}

extension ViewControllerCopyFiles: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerCopyFiles: GetPath {
    func pathSet(path: String?, requester: WhichPath) {
        if let setpath = path {
            self.localCatalog.stringValue = setpath
        }
    }
}

extension ViewControllerCopyFiles: SetIndex {
    func setIndex(index: Int) {
        self.index = index
        self.displayRemoteserver(index: index)
    }
}

extension ViewControllerCopyFiles: GetSource {
    func getSource(index: Int) {
        self.index = index
        guard self.configurations!.getConfigurations()[self.index!].offsiteServer.isEmpty == false else {
            self.copyButton.isEnabled = false
            self.sourceButton.isEnabled = false
            self.info(num: 2)
            return
        }
        self.displayRemoteserver(index: index)
        if let index = self.index {
            self.copyFiles = CopyFiles(index: index)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: index)
        }
    }
}
