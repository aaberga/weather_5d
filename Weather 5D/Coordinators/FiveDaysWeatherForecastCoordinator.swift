//
//  FiveDaysWeatherForecastCoordinator.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import UIKit
import SwiftyJSON


class FiveDaysWeatherForecastCoordinator: Coordinator {
    
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
    
        if let result = result as? JSON {
            
//            print("Result: \(result)")
            if let viewController = self.viewController as? FiveDaysWeatherController {
                
                viewController.forecast.text = result.description
            }
            
        } else if let error = error {
            
//            print("Error: \(error)")
            if let viewController = self.viewController as? FiveDaysWeatherController {
                
                viewController.forecast.text = error.localizedDescription
            }
        }
    }
}
