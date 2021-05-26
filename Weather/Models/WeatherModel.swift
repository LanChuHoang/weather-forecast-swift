//
//  WeatherModel.swift
//  Weather
//
//  Created by Lan Chu on 5/4/21.
//

import Foundation

class WeatherModel: Decodable {
    var city = City()
    var iconInfo = WeatherIconInfo()
    var temperature: Float = 0.0
    var pressure: Int = 0
    var visibility: Int = 0
    var humidity: Int = 0
    
    var forecast: Forecast?
    
    enum OuterKeys: String, CodingKey {
        case coord
        case weather
        case main
        case visibility
        case timezone
        case name
    }
    
    enum CoordKeys: String, CodingKey {
        case lat
        case lon
    }
    
    enum WeatherKeys: String, CodingKey {
        case description
        case icon
    }
    
    enum mainKeys: String, CodingKey {
        case temp
        case pressure
        case humidity
    }
    
    
    required init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterKeys.self)
        let coordContainer = try outerContainer.nestedContainer(keyedBy: CoordKeys.self, forKey: OuterKeys.coord)
        let iconInfoArray = try outerContainer.decode([WeatherIconInfo].self, forKey: OuterKeys.weather)
        let mainContainer = try outerContainer.nestedContainer(keyedBy: mainKeys.self, forKey: OuterKeys.main)
        
        self.city.name = try outerContainer.decode(String.self, forKey: OuterKeys.name)
        self.city.latitude = try coordContainer.decode(Float.self, forKey: CoordKeys.lat)
        self.city.longitude = try coordContainer.decode(Float.self, forKey: CoordKeys.lon)
        self.city.timezone = try outerContainer.decode(Int.self, forKey: OuterKeys.timezone)
//        print(self.city.name)
//        print(self.city.coordinate.lat)
//        print(self.city.coordinate.lon)
//        print(self.city.timezone)
        self.iconInfo = iconInfoArray[0]
//        print(iconInfo.iconName)
//        print(iconInfo.description)
        self.temperature =  try mainContainer.decode(Float.self, forKey: mainKeys.temp)
        self.pressure = try mainContainer.decode(Int.self, forKey: mainKeys.pressure)
        self.visibility = try outerContainer.decode(Int.self, forKey: OuterKeys.visibility)
        self.humidity = try mainContainer.decode(Int.self, forKey: mainKeys.humidity)
//        print(self.temperature)
//        print(self.pressure)
//        print(self.visibility)
//        print(self.humidity)
        
    }
    
    func printData() {
        print("- City: " + city.name)
        print("\t+ Coordinate: lat = \(city.latitude) + lon = \(city.longitude)")
        print("\t+ Timezone: \(city.timezone)")
        print("- Description: \(iconInfo.description)")
        print("- Icon name: \(iconInfo.iconName)")
        print("- Temperature: \(temperature)")
        print("- Pressure: \(pressure)")
        print("- Visibility: \(visibility)")
        print("- Humidity: \(humidity)")
        print("\n- Forecast: ")
        if forecast != nil {
            print("\n- Hourly: ")
            for data in forecast!.hourly {
                print("\t- iconName: \(data.iconInfo.iconName)")
                print("\t\t+ temperature: \(data.temperature)")
                print("\t\t+ time: \(data.time)")
            }
            
            print("\n- Daily: ")
            for data in forecast!.daily {
                print("\t- iconName: \(data.iconInfo.iconName)")
                print("\t- description: \(data.iconInfo.description)")
                print("\t\t+ temperature: \(data.tempMin) - \(data.tempMax)")
                print("\t\t+ time: \(data.time)")
            }
        }

    }

    var temperatureString: String {
        get {
            return "\(Int(temperature))°"
        }
    }
    var pressureString: String {
        get {
            return "\(pressure)hPa"
        }
    }
    var visibilityString: String {
        get {
            return "\(visibility/1000) Km"
        }
    }
    var humidityString: String {
        get {
            return "\(humidity)%"
        }
    }
}


