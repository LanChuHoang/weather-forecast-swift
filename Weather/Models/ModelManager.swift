//
//  ModelManager.swift
//  Weather
//
//  Created by Lan Chu on 5/25/21.
//
import Foundation
import CoreLocation

protocol WeatherDataDelegate {
    func didUpdate(with data: WeatherModel)
    func didFail(with error: Error)
}


class ModelManager {
    var delegate: WeatherDataDelegate?
    var weatherModel: WeatherModel?
    private let baseDataURL = "https://api.openweathermap.org/data/2.5/weather?appid=4c96a85087feb90367949fe7c36bd34e&units=metric"
    private let baseForecastURL = "https://api.openweathermap.org/data/2.5/onecall?appid=4c96a85087feb90367949fe7c36bd34e&units=metric&exclude=minutely"
    
    //MARK: - WeatherData
    func fetchWeatherData(cityName: String) {
        let convertedName = clearCityName(for: cityName)
        let url = URL(string: baseDataURL + "&q=" + convertedName)!
        performRequest(with: url) { (result) in
            switch result {
            case .success(let data):
//                self.printJSON(data: data)
                do {
                    let decodedData = try JSONDecoder().decode(WeatherModel.self, from: data)
                    self.weatherModel = decodedData
                    self.fetchForecastData(lat: decodedData.city.latitude, lon: decodedData.city.longitude)
                } catch {
                    print("JSON decoding error: \(error)")
                    self.delegate?.didFail(with: error)
                }
            case .failure(let error):
                self.delegate?.didFail(with: error)
            }
        }
    }
    
    func fetchWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = URL(string: baseDataURL + "&lat=\(latitude)&lon=\(longitude)")!
        performRequest(with: url) { (result) in
            switch result {
            case .success(let data):
//                self.printJSON(data: data)
                do {
                    let decodedData = try JSONDecoder().decode(WeatherModel.self, from: data)
                    self.weatherModel = decodedData
                    self.fetchForecastData(lat: decodedData.city.latitude, lon: decodedData.city.longitude)
                } catch {
                    print("JSON decoding error: \(error)")
                    self.delegate?.didFail(with: error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func clearCityName(for cityName: String) -> String{
        // replace space + diacritic + tolower
        let cleanName = cityName.replacingOccurrences(of: " ", with: "").lowercased().folding(options: .diacriticInsensitive, locale: .current)
        switch cleanName {
        case "hochiminh", "hochiminhcity", "thanhphohochiminh", "hcm", "tphcm", "hcmcity":
            return "saigon"
        default:
            return cleanName
        }
    }
    
    //MARK: - ForecastData
    func fetchForecastData(lat: Float, lon: Float) {
        let url = URL(string: baseForecastURL + "&lat=\(lat)&lon=\(lat)")!
        performRequest(with: url) { (result) in
            switch result {
            case .success(let data):
//                self.printJSON(data: data)
                do {
                    if self.weatherModel != nil {
                        self.weatherModel!.forecast = try JSONDecoder().decode(Forecast.self, from: data)
                        self.delegate?.didUpdate(with: self.weatherModel!)
                    } else {
                        print("weatherModel is nil")
                    }
                } catch {
                    self.delegate?.didFail(with: error)
                }
            case .failure(let error):
                self.delegate?.didFail(with: error)
            }
        }
    }
    
    func performRequest(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            // Check the error and data nil or not
            guard error == nil, data != nil else {
                print("Client error")
                completion(.failure(error!))
                return
            }
            // Check the response of the HTTPs request
            // If the status code is not in [200..299] -> fail
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error")
                return
            }
            // Check the type of the DATA is JSON or not - using MIME type in the response
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type, the data is not json")
                return
            }
            
            // No error -> parse JSON data to a WeatherData object -> call the delegate object to do the update function
            completion(.success(data!))
        }
        
        // 4. Resume the task -  Because when we create the task it is in suspended state
        task.resume()
    }
    

    
    func printJSON(data: Data) {
        do {
            let jsonString = try JSONSerialization.jsonObject(with: data, options: [])
            print(jsonString)
        } catch {
            print("JSON to string error: \(error)")
        }
    }
}
