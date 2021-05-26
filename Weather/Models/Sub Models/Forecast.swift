//
//  Forecast.swift
//  Weather
//
//  Created by Lan Chu on 5/25/21.
//

import Foundation

class Forecast: Decodable {
    var hourly: [HourlyForecast]
    var daily: [DailyForecast]
    
    enum CodingKeys: String, CodingKey {
        case hourly
        case daily
    }
}
