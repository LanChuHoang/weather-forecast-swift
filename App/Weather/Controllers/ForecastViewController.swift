//
//  ForecastViewController.swift
//  Weather
//
//  Created by Lan Chu on 5/26/21.
//

import UIKit

class ForecastViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var dailyForecast: [DailyForecast]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DailyForecastCell", bundle: nil), forCellReuseIdentifier: "DailyForecastCell")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForecast?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastCell", for: indexPath) as! DailyForecastCell
        
        let currentForecast = dailyForecast![indexPath.row]
        let date = Date(timeIntervalSince1970: TimeInterval(currentForecast.time))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        cell.dateLabel.text = formatter.string(from: date)
        
        cell.tempMaxLabel.text = "\(Int(currentForecast.tempMax))°"
        cell.tempMinLabel.text = "\(Int(currentForecast.tempMin))°"
        cell.iconImageView.image = UIImage(named: currentForecast.iconInfo.iconName)
        cell.descriptionLabel.text = currentForecast.iconInfo.description
        return cell;
    }
    
    
}
