//
//  Forcast.swift
//  Weather
//
//  Created by Lan Chu on 5/25/21.
//

import Foundation

class Forecast: Decodable {
    var hourlyForecast: [HourlyForecast]
    var dailyForecast: [DailyForecast]
}
