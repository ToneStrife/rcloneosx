//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class Schedules: ScheduleWriteLoggData {

    var profile: String?

    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule] {
        return self.schedules ?? []
    }

    /// Function adds new Shcedules (plans). Functions writes
    /// schedule plans to permanent store.
    /// - parameter hiddenID: hiddenID for task
    /// - parameter schedule: schedule
    /// - parameter start: start date and time
    /// - parameter stop: stop date and time
    func addschedule (_ hiddenID: Int, schedule: Scheduletype, start: Date) {
        var stop: Date?
        let dateformatter = Dateandtime().setDateformat()
        if schedule == .once {
            stop = start
        } else {
            stop = dateformatter.date(from: "01 Jan 2100 00:00")
        }
        let dict = NSMutableDictionary()
        dict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
        dict.setObject(dateformatter.string(from: start), forKey: "dateStart" as NSCopying)
        dict.setObject(dateformatter.string(from: stop!), forKey: "dateStop" as NSCopying)
        switch schedule {
        case .once:
            dict.setObject("once", forKey: "schedule" as NSCopying)
        case .daily:
            dict.setObject("daily", forKey: "schedule" as NSCopying)
        case .weekly:
            dict.setObject("weekly", forKey: "schedule" as NSCopying)
        }
        let newSchedule = ConfigurationSchedule(dictionary: dict, log: nil, nolog: true)
        self.schedules!.append(newSchedule)
        self.storageapi!.saveScheduleFromMemory()
        self.reloadtable(vcontroller: .vctabschedule)
    }

    /// Function deletes all Schedules by hiddenID. Invoked when Configurations are
    /// deleted. When a Configuration are deleted all tasks connected to
    /// Configuration has to  be deleted.
    /// - parameter hiddenID : hiddenID for task
    func deletescheduleonetask(hiddenID: Int) {
        var delete: Bool = false
        for i in 0 ..< self.schedules!.count where self.schedules![i].hiddenID == hiddenID {
            // Mark Schedules for delete
            // Cannot delete in memory, index out of bound is result
            self.schedules![i].delete = true
            delete = true
        }
        if delete {
            self.storageapi!.saveScheduleFromMemory()
            // Send message about refresh tableView
            self.reloadtable(vcontroller: .vctabmain)
        }
    }

    /// Function reads all Schedule data for one task by hiddenID
    /// - parameter hiddenID : hiddenID for task
    /// - returns : array of Schedules sorted after startDate
    func readscheduleonetask (_ hiddenID: Int?) -> [NSMutableDictionary]? {
        guard hiddenID != nil else { return nil }
        var row: NSMutableDictionary
        var data = [NSMutableDictionary]()
        for i in 0 ..< self.schedules!.count {
            if self.schedules![i].hiddenID == hiddenID {
                row = [
                    "dateStart": self.schedules![i].dateStart,
                    "stopCellID": 0,
                    "deleteCellID": 0,
                    "dateStop": "",
                    "schedule": self.schedules![i].schedule,
                    "hiddenID": schedules![i].hiddenID,
                    "numberoflogs": String(schedules![i].logrecords.count)
                ]
                if self.schedules![i].dateStop == nil {
                    row.setValue("no stop date", forKey: "dateStop")
                } else {
                    row.setValue(self.schedules![i].dateStop, forKey: "dateStop")
                }
                if self.schedules![i].schedule == "stopped" {
                    row.setValue(1, forKey: "stopCellID")
                }
                data.append(row)
            }
            // Sorting schedule after dateStart, last startdate on top
            data.sort { (sched1, sched2) -> Bool in
                let dateformatter = Dateandtime().setDateformat()
                if dateformatter.date(from: (sched1.value(forKey: "dateStart") as? String)!)! >
                    dateformatter.date(from: (sched2.value(forKey: "dateStart") as? String)!)! {
                    return true
                } else {
                    return false
                }
            }
        }
        return data
    }

    /// Function either deletes or stops Schedules.
    /// - parameter data : array of Schedules which some of them are either marked for stop or delete
    func deleteorstopschedule(data: [NSMutableDictionary]) {
        var update: Bool = false
        if (data.count) > 0 {
            let stop = data.filter({ return (($0.value(forKey: "stopCellID") as? Int) == 1)})
            let delete = data.filter({ return (($0.value(forKey: "deleteCellID") as? Int) == 1)})
            // Delete Schedules
            if delete.count > 0 {
                update = true
                for i in 0 ..< delete.count {
                    self.delete(dict: delete[i])
                }
            }
            // Stop Schedules
            if stop.count > 0 {
                update = true
                for i in 0 ..< stop.count {
                    self.stop(dict: stop[i])
                }
            }
            if update {
                // Saving the resulting data file
                self.storageapi!.saveScheduleFromMemory()
                // Send message about refresh tableView
                self.reloadtable(vcontroller: .vctabmain)
            }
        }
    }

    // Test if Schedule record in memory is set to delete or not
    private func delete(dict: NSDictionary) {
        loop :  for i in 0 ..< self.schedules!.count {
            if dict.value(forKey: "hiddenID") as? Int == self.schedules![i].hiddenID {
                if dict.value(forKey: "dateStop") as? String == self.schedules![i].dateStop ||
                    self.schedules![i].dateStop == nil &&
                    dict.value(forKey: "schedule") as? String == self.schedules![i].schedule &&
                    dict.value(forKey: "dateStart") as? String == self.schedules![i].dateStart {
                    self.schedules![i].delete = true
                    break
                }
            }
        }
    }

    // Test if Schedule record in memory is set to stop er not
    private func stop(dict: NSDictionary) {
        loop :  for i in 0 ..< self.schedules!.count where
            dict.value(forKey: "hiddenID") as? Int == self.schedules![i].hiddenID {
                if dict.value(forKey: "dateStop") as? String == self.schedules![i].dateStop ||
                    self.schedules![i].dateStop == nil &&
                    dict.value(forKey: "schedule") as? String == self.schedules![i].schedule &&
                    dict.value(forKey: "dateStart") as? String == self.schedules![i].dateStart {
                    self.schedules![i].schedule = "stopped"
                    break
                }
        }
    }

    // Check if hiddenID is in Scheduled tasks
    func hiddenIDinSchedule(_ hiddenID: Int) -> Bool {
        let result = self.schedules!.filter({return ($0.hiddenID == hiddenID && $0.dateStop != nil)})
        if result.isEmpty {
            return false
        } else {
            return true
        }
    }

    // Returning the set of executed tasks for å schedule.
    // Used for recalcutlate the parent key when task change schedule
    // from active to "stopped"
    private func getScheduleExecuted(_ hiddenID: Int) -> [NSMutableDictionary]? {
        var result = self.schedules!.filter({return ($0.hiddenID == hiddenID) && ($0.schedule == "stopped")})
        if result.count > 0 {
            let schedule = result.removeFirst()
            return schedule.logrecords
        } else {
            return nil
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    private func readschedules() {
        var store: [ConfigurationSchedule]? = self.storageapi!.getScheduleandhistory(nolog: false)
        guard store != nil else { return }
        var data = [ConfigurationSchedule]()
        for i in 0 ..< store!.count {
            data.append(store![i])
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        // Setting self.Schedule as data
        self.schedules = data
    }

    init(profile: String?) {
        super.init()
        self.profile = profile
        self.storageapi = PersistentStorageAPI(profile: self.profile)
        self.readschedules()
    }
}
