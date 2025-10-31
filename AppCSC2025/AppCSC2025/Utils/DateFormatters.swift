//
//  DateFormatters.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import Foundation

enum DateFormatters {
    static let monthAbbrev: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "MMM"
        return f
    }()

    static let dayNumber: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "d"
        return f
    }()

    static let timeShort: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
}

extension Date {
    var monthAbbrev: String { DateFormatters.monthAbbrev.string(from: self) }
    var dayNumber: String { DateFormatters.dayNumber.string(from: self) }
    var timeShort: String { DateFormatters.timeShort.string(from: self) }
}
