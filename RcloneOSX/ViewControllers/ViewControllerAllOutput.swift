//
//  ViewControllerAllOutput.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 10.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerAllOutput: NSViewController, Delay {
    
    @IBOutlet weak var detailsTable: NSTableView!
    weak var getoutputDelegate: StoreAllOutput?
    var lastindex: Int = 0
    
    @IBAction func clearoutput(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcalloutput, nsviewcontroller: self)
        self.getoutputDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.lastindex = 0
        self.getoutputDelegate?.disableallinfobutton()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.getoutputDelegate?.enableallinfobutton()
    }
    
}

extension ViewControllerAllOutput: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.getoutputDelegate?.getalloutput().count ?? 0
    }
}

extension ViewControllerAllOutput: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.getoutputDelegate?.getalloutput()[row] ?? ""
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension ViewControllerAllOutput: Reloadandrefresh {
    func reloadtabledata() {
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
        self.lastindex = -1000
        var outputcount = self.getoutputDelegate?.getalloutput().count ?? 0
        while self.lastindex < outputcount {
            self.lastindex = self.getoutputDelegate?.getalloutput().count ?? 0
            self.delayWithSeconds(2) {
                outputcount = self.getoutputDelegate?.getalloutput().count ?? 0
                if outputcount == self.lastindex {
                    self.lastindex = +1000
                }
                globalMainQueue.async(execute: { () -> Void in
                    self.detailsTable.reloadData()
                })
            }
        }
        print("completed")
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }
}
