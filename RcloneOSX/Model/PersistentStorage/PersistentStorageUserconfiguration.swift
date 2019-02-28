//
//  PersistentStoreageUserconfiguration.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable function_body_length 

import Foundation

final class PersistentStorageUserconfiguration: ReadWriteDictionary, SetConfigurations {

    /// Variable holds all configuration data
    var userconfiguration: [NSDictionary]?

    // Saving user configuration
    func saveUserconfiguration () {
        var optionalpathrclone: Int?
        var detailedlogging: Int?
        var minimumlogging: Int?
        var fulllogging: Int?
        var rclonePath: String?
        var restorePath: String?
        var marknumberofdayssince: String?
        var rclone143: Int?

        if ViewControllerReference.shared.rcloneopt {
            optionalpathrclone = 1
        } else {
            optionalpathrclone = 0
        }
        if ViewControllerReference.shared.detailedlogging {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if ViewControllerReference.shared.minimumlogging {
            minimumlogging = 1
        } else {
            minimumlogging = 0
        }
        if ViewControllerReference.shared.fulllogging {
            fulllogging = 1
        } else {
            fulllogging = 0
        }
        if ViewControllerReference.shared.rclonePath != nil {
            rclonePath = ViewControllerReference.shared.rclonePath!
        }
        if ViewControllerReference.shared.restorePath != nil {
            restorePath = ViewControllerReference.shared.restorePath!
        }
        if ViewControllerReference.shared.rclone143 != nil {
            rclone143 = 1
        } else {
            rclone143 = 0
        }
        var array = [NSDictionary]()
        marknumberofdayssince = String(ViewControllerReference.shared.marknumberofdayssince)
        let dict: NSMutableDictionary = [
            "optionalpathrclone": optionalpathrclone! as Int,
            "detailedlogging": detailedlogging! as Int,
            "minimumlogging": minimumlogging! as Int,
            "fulllogging": fulllogging! as Int,
            "marknumberofdayssince": marknumberofdayssince ?? "5.0",
            "rclone143": rclone143! as Int]

        if rclonePath != nil {
            dict.setObject(rclonePath!, forKey: "rclonePath" as NSCopying)
        }
        if restorePath != nil {
            dict.setObject(restorePath!, forKey: "restorePath" as NSCopying)
        } else {
            dict.setObject("", forKey: "restorePath" as NSCopying)
        }
        array.append(dict)
        self.writeToStore(array)
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore (_ array: [NSDictionary]) {
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeNSDictionaryToPersistentStorage(array)
    }

    init (readfromstorage: Bool) {
        super.init(whattoreadwrite: .userconfig, profile: nil, configpath: ViewControllerReference.shared.configpath)
        if readfromstorage {
            self.userconfiguration = self.readNSDictionaryFromPersistentStore()
        }
    }
}
