//
//  ViewController.swift
//  Weather
//
//  Created by Lan Chu on 5/1/21.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temparatureLabel: UILabel!
    @IBOutlet weak var weatherDescripLabel: UILabel!
    
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    
    let modelManager = ModelManager()
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, hh:mm a"
        return formatter
    }()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assign the delegates
        searchTextField.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        modelManager.delegate = self
        locationManager.delegate = self
        
        // UI things
        infoView.layer.cornerRadius = 20
        
        // Get the user's location data
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        modelManager.fetchWeatherData(cityName: "hanoi")
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? ForecastViewController {
            destVC.dailyForecast = modelManager.weatherModel?.forecast?.daily
        }
    }
}

//MARK: - CoreLocation LocationManagerDelegate Methods
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Force upwrap because the locaitons array always have at least 1 element
        let lastestLocationData = locations.last!
        locationManager.stopUpdatingLocation()
        modelManager.fetchWeatherData(latitude: lastestLocationData.coordinate.latitude, longitude: lastestLocationData.coordinate.longitude)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location request error: \(error)")
    }
}


//MARK: - UITextFieldDelegate Methods

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let searchCity = searchTextField.text, searchCity != "" {
            modelManager.fetchWeatherData(cityName: searchCity)
            searchTextField.text = ""
        }
    }
}


//MARK: - WeatherDataDelegate Methods

extension HomeViewController: WeatherDataDelegate {
    func didUpdate(with data: WeatherModel) {
        DispatchQueue.main.async { [self] in
            cityNameLabel.text = data.city.name
            
            dateFormatter.timeZone = TimeZone(secondsFromGMT: data.city.timezone)
            dateFormatter.dateFormat = "EEEE, hh:mm a"
            dateLabel.text = dateFormatter.string(from: Date())
            
            weatherImageView.image = UIImage(named: data.iconInfo.iconName)
            temparatureLabel.text = data.temperatureString
            weatherDescripLabel.text = data.iconInfo.description
            pressureLabel.text = data.pressureString
            visibilityLabel.text = data.visibilityString
            humidityLabel.text = data.humidityString
            
            collectionView.reloadData()
        }
        
    }
    
    func didFail(with error: Error) {
        print(error)
    }
}

//MARK: - UICollectionView
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelManager.weatherModel?.forecast?.hourly.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCell", for: indexPath) as! HourlyForecastCell
        if let forecast = modelManager.weatherModel?.forecast?.hourly {
            let currentForecast = forecast[indexPath.row]
            cell.iconImageView.image = UIImage(named: currentForecast.iconInfo.iconName)
            cell.temperatureLabel.text = currentForecast.temperatureString
            
            
            
            let formatter = DateFormatter()
            let date = Date(timeIntervalSince1970: TimeInterval(currentForecast.time))
            
            if indexPath.row == 0 {
                cell.timeLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
                cell.timeLabel.textColor = .black
                cell.timeLabel.text = "now"
                
            } else if (currentForecast.time + 7*3600) % 86400 == 0 {
                cell.timeLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
                cell.timeLabel.textColor = .black
                formatter.dateFormat = "dd/MM"
                cell.timeLabel.text = formatter.string(from: date)
            } else {
                cell.timeLabel.font = UIFont.systemFont(ofSize: 14.0)
                cell.timeLabel.textColor = .darkGray
                formatter.dateFormat = "hh a"
                cell.timeLabel.text = formatter.string(from: date)
            }
//            cell.timeLabel.text = formattedDate
            
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if modelManager.weatherModel == nil || modelManager.weatherModel!.forecast == nil {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: (collectionView.frame.width-4*10)/5, height: collectionView.frame.height*0.8)
    }
}

