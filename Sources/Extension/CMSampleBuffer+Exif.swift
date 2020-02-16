//
//  CMSampleBuffer+Exif.swift
//  HaishinKit iOS
//
//  Created by Mats ten Bohmer on 16/02/2020.
//  Copyright © 2020 Shogo Endo. All rights reserved.
//
import Foundation
import CoreMedia


extension CMSampleBuffer {
    /// Custom property. Extracts datetime information from the exif attachment, including subsec information. Millisecond accuracy.
    var exifMillisecondsSince1970: Int64? {
        if let metadata = CMGetAttachment(self, key: "{Exif}" as CFString, attachmentModeOut: nil) as? NSDictionary {
            if let dateTimeOriginal = metadata.value(forKey: "DateTimeOriginal") as? NSString {
                if let date = ExifDateFormatter.shared.date(from: (dateTimeOriginal as String) + ExifDateFormatter.useTimezoneString),
                    let subsecTimeOriginal = metadata.value(forKey: "SubsecTimeOriginal") as? NSString {
                    return date.millisecondsSince1970 + Int64(subsecTimeOriginal as String)!
                }
            }
        }
        return nil
    }
}

class ExifDateFormatter: DateFormatter {
    static let shared = build()

    private(set) static var useTimezoneString = ""

    private static func build() -> DateFormatter {
        let obj = DateFormatter()

        // 2019:10:26 13:22:20+02:00
        obj.dateFormat = "yyyy:MM:dd HH:mm:ssZZZZZ"

        // Collect the timezone string.
        let tzdf = DateFormatter()
        tzdf.dateFormat = "ZZZZZ"
        useTimezoneString = tzdf.string(from: Date())

        return obj
    }
}
