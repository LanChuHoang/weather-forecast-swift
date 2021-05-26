//
//  WeatherIconInfo.swift
//  Weather
//
//  Created by Lan Chu on 5/25/21.
//

import Foundation

class WeatherIconInfo: Decodable {
    var iconName: String = "01n"
    var description: String = ""
    
    enum CodingKeys: String, CodingKey {
        case iconName = "icon"
        case description
    }
}
