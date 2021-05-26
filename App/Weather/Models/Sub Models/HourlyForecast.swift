//
//  HourlyForecast.swift
//  Weather
//
//  Created by Lan Chu on 5/25/21.
//

import Foundation

class HourlyForecast: Decodable {
    var iconInfo: WeatherIconInfo = WeatherIconInfo()
    var temperature: Float = 0.0
    var time: Int = 0
    
    enum OuterKeys: String, CodingKey {
        case temperature = "temp"
        case time = "dt"
        case weather
    }
    
    required init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterKeys.self)
        let iconInfoArray = try outerContainer.decode([WeatherIconInfo].self, forKey: OuterKeys.weather)
        
        self.iconInfo = iconInfoArray[0]
        self.temperature = try outerContainer.decode(Float.self, forKey: OuterKeys.temperature)
        self.time = try outerContainer.decode(Int.self, forKey: OuterKeys.time)
    }
    
    var temperatureString: String {
        get {
            return "\(Int(temperature))°"
        }
    }
}
