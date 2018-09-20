//
//  OpenWeatherMapService.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import Foundation



enum RequestType: String {
    
    case fiveDaysForecast
}


enum RequestParameter: String {
    
    case city
    case api
}


class OpenWeatherMapService: DataService {
    
    // MARK: Properties

        //
    
    // MARK: Generic Service Interface
    
    func obtainEntityFor(key: String, withParameters passedData: [String: Any]?, andOnCompletion completionBlock: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        
        switch key {
            
        case RequestType.fiveDaysForecast.rawValue:
            
            if let targetCity = passedData?[RequestParameter.city.rawValue] as? String {
                
                self.getFiveDaysForecastFor(city: targetCity, andOnCompletion: completionBlock)
            }
            
        default:
            break
        }
    }
    
    
    // MARK: Specific OWM Service Interface
    
    func getFiveDaysForecastFor(city: String, andOnCompletion completionBlock: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        
        let sampleResourceFileName = "OpenWeatherMapSampleData"
        let sampleJSONData = Helpers.readJSON(from: sampleResourceFileName)
        
        completionBlock(sampleJSONData, nil)
    }
}


