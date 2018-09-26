//
//  FiveDaysWeatherForecastCoordinator.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import UIKit
import SwiftyJSON


class FiveDaysWeatherForecastCoordinator: NSObject, Coordinator {
    
    // MARK: Coordinator Properties
    
    var viewController: UIViewController
    var dataService = OpenWeatherMapService()
    
    // MARK: Coordinator Methods
    
    func start() {
        
        if let viewController = self.viewController as? FiveDaysWeatherController {
            
            viewController.delegate = self
        }
    }
    
    // MARK: Coordinator LifeCycle
    
    init(targetViewController: UIViewController) {
        
        self.viewController = targetViewController
    }
    
    
    // MARK: Private Coordinator Properties
    
    private var currentForecast: FiveDaysServiceResponse?
    private var currentError: Error?
}


extension FiveDaysWeatherForecastCoordinator: FiveDaysWeatherForecastDelegate {
    
    func getForecast(for city: String) {
        
        self.dataService.getFiveDaysForecastFor(city: city, andOnCompletion: { result, error in
            
            self.displayServiceOutcome(result, error)
        })
    }
}


extension FiveDaysWeatherForecastCoordinator {
    
    func displayServiceOutcome(_ result: Any?, _ error: Error?) -> Void {
    
        if let obtainedForecast = result as? FiveDaysServiceResponse {
            
            if let viewController = self.viewController as? FiveDaysWeatherController {
                
//                DLogWith(message: "Weather Data: \(result)")
                
                self.currentForecast = obtainedForecast
                self.currentError = nil
                
                DispatchQueue.main.async {
                    
                    viewController.displayForecast(from: self, with: self)
                }
            }
            
        } else if let error = error {
            
            if let viewController = self.viewController as? FiveDaysWeatherController {
                
//                DLogWith(message: "Error Data: \(error.localizedDescription)")
                self.currentForecast = nil
                self.currentError = error
                
                DispatchQueue.main.async {

                    viewController.displayForecast(from: self, with: self)
                }
            }
        }
    }
}



// MARK: - Table View DataSource

extension FiveDaysWeatherForecastCoordinator: UITableViewDataSource {
    
    // Cells: CityCell, ForecastCell, ErrorCell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowNo = indexPath.row
        var cell: UITableViewCell!
        
        if rowNo == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath as IndexPath)
            
            let forecastCity = self.currentForecast?.city
            
            if let forecastCity = forecastCity, let cityLabel = cell.viewWithTag(100) as? UILabel {
                cityLabel.text = forecastCity.name
            }
            
            if let forecastCity = forecastCity, let cityLabel = cell.viewWithTag(101) as? UILabel {
                cityLabel.text = forecastCity.country
            }

        } else {
            
            if let error = self.currentError {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath as IndexPath)
                
                if let errorLabel = cell.viewWithTag(100) as? UILabel {
                    errorLabel.text = error.localizedDescription
                }

            } else {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath as IndexPath)
                
                let forecastInfo = self.currentForecast?.forecastData[rowNo-1]
                
                if let forecastInfo = forecastInfo, let forecastLabel = cell.viewWithTag(100) as? UILabel {
                    
                    let forecastText = forecastInfo.dateText + " - \(forecastInfo.weatherText)"
                    forecastLabel.text = forecastText
                }
                
                if let forecastInfo = forecastInfo, let forecastLabel = cell.viewWithTag(101) as? UILabel {
                    
                    let forecastText = String((forecastInfo.temperature - 272.15).rounded(toPlaces: 0))
                    forecastLabel.text = forecastText
                }
                
                if let forecastInfo = forecastInfo, let forecastLabel = cell.viewWithTag(102) as? UILabel {
                    
                    let forecastText = String(forecastInfo.pressure.rounded(toPlaces: 1))
                    forecastLabel.text = forecastText
                }
                
                if let forecastInfo = forecastInfo, let forecastLabel = cell.viewWithTag(103) as? UILabel {
                    
                    let forecastText = String(forecastInfo.clouds.rounded(toPlaces: 1))
                    forecastLabel.text = forecastText
                }
                
                if let forecastInfo = forecastInfo, let forecastLabel = cell.viewWithTag(104) as? UILabel {
                    
                    let forecastText = String(forecastInfo.windSpeed.rounded(toPlaces: 1)) + " / " + String(forecastInfo.windDirection.rounded(toPlaces: 1))
                    forecastLabel.text = forecastText
                }
            }
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let currentForecast = self.currentForecast {
            
            let dataPoints = currentForecast.forecastData.count
            
            return dataPoints + 1
        }
        return 0
    }
}

// MARK: - Table View Delegate

extension FiveDaysWeatherForecastCoordinator: UITableViewDelegate {
  
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!)!
        print(currentCell.textLabel!.text!)
    }
    */
}
