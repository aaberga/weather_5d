//
//  ViewController.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import UIKit


protocol FiveDaysWeatherForecastDelegate: class {
    
    func getForecast(for city: String)
}

protocol FiveDaysWeatherForecastDisplay: class {
    
    func displayForecast(from tableDelegate: UITableViewDelegate, with tableDataSource: UITableViewDataSource)
}


class FiveDaysWeatherController: UIViewController, UITextFieldDelegate {

    // MARK: Public Properties
    
    var delegate: FiveDaysWeatherForecastDelegate?
    
    // MARK: IBActions
    
        //
    
    // MARK: IBOutlets

    @IBOutlet weak var targetCity: UITextField!
    @IBOutlet weak var forecast: UITableView!
    
    // MARK: TextField Delegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.targetCity {
            
            //self.forecast.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.targetCity {

            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.targetCity {
            
            if let cityString = textField.text {
                self.delegate?.getForecast(for: cityString)
            }
        }
    }
    
    
    // MARK: Private Properties
    
    var tableViewDelegate: UITableViewDelegate?
    var tableViewDataSource: UITableViewDataSource?

}

extension FiveDaysWeatherController: FiveDaysWeatherForecastDisplay {
    
    func displayForecast(from tableDelegate: UITableViewDelegate, with tableDataSource: UITableViewDataSource) {
        
        self.tableViewDelegate = tableDelegate
        self.tableViewDataSource = tableDataSource

        self.forecast.delegate = self.tableViewDelegate
        self.forecast.dataSource = self.tableViewDataSource
        
        self.forecast.reloadData()
    }
}
