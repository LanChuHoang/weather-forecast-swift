//
//  DailyForecast.swift
//  Weather
//
//  Created by Lan Chu on 5/25/21.
//

import Foundation

class DailyForecast: Decodable {
    var iconInfo: WeatherIconInfo = WeatherIconInfo()
    var tempMax: Float = 0.0
    var tempMin: Float = 0.0
    var time: Int = 0
    
    enum OuterKey: String, CodingKey {
        case temp
        case time = "dt"
        case weather
    }
    
    enum TempKeys: String, CodingKey {
        case tempMax = "max"
        case tempMin = "min"
    }
    
    required init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterKey.self)
        let tempContainer = try outerContainer.nestedContainer(keyedBy: TempKeys.self, forKey: OuterKey.temp)
        let iconInfoArray = try outerContainer.decode([WeatherIconInfo].self, forKey: OuterKey.weather)
        
        self.iconInfo = iconInfoArray[0]
        self.tempMax = try tempContainer.decode(Float.self, forKey: TempKeys.tempMax)
        self.tempMin = try tempContainer.decode(Float.self, forKey: TempKeys.tempMin)
        self.time = try outerContainer.decode(Int.self, forKey: OuterKey.time)
    }
    
}
