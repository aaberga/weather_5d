//
//  OpenWeatherMapService.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import Foundation
import SwiftyJSON


private let kOpenWeatherMapAPIKey = "5f0f94b44eab3e3040fe2750f430b8bd"
private let kErrorDomain = "FiveDaysForecast"

enum RequestType: String {
    
    case fiveDaysForecast
}


enum RequestParameter: String {
    
    case city
    case country
    case api
}


class OpenWeatherMapService: DataService {
    
    // MARK: Properties

        // No Props
    
    // MARK: Generic Service Interface
    
    func obtainEntityFor(key: String, withParameters passedData: [String: Any]?, andOnCompletion completionBlock: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        
        switch key {
            
        case RequestType.fiveDaysForecast.rawValue:
            
            if let targetCity = passedData?[RequestParameter.city.rawValue] as? String,
                let targetCountry = passedData?[RequestParameter.country.rawValue] as? String {
                
                self.getFiveDaysForecastFor(city: targetCity, country: targetCountry, andOnCompletion: completionBlock)
                
            } else if let targetCity = passedData?[RequestParameter.city.rawValue] as? String {
                
                self.getFiveDaysForecastFor(city: targetCity, andOnCompletion: completionBlock)
                
            } else {
                
                let parametersError: NSError? = NSError(domain: kErrorDomain, code: 1001, userInfo: ["ErrorString": "Insufficient/Wrong Parameters Passed In API Call"])
                completionBlock(nil, parametersError)
            }
            
        default:
            
            let parametersError: NSError? = NSError(domain: kErrorDomain, code: 1002, userInfo: ["ErrorString": "Wrong API Request In API Call"])
            completionBlock(nil, parametersError)
        }
    }
    
    
    // MARK: Specific OWM Service Interface
    
    func getFiveDaysForecastFor(city: String, country: String? = nil, andOnCompletion completionBlock: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        
        func transformResponseToModel(_ result: Any?, _ error: Error?) -> Void {
            
            var fiveDaysForecast: FiveDaysServiceResponse?
            var targetCity: City?
            var forecastPoints: [ForecastPoint]?

            var apiError: NSError?
            
            let json = result as? JSON
            
//            DLogWith(message: "JSON: \(String(describing: json))")
            
            if let forecastJson = json {
                
                if let forecastCityData = forecastJson["city"].dictionary {
                    
                    let cityName = forecastCityData["name"]?.string
                    let countryName = forecastCityData["country"]?.string
                    
                    if let cityName = cityName, let countryName = countryName {
                        
                        targetCity = City(name: cityName, country: countryName)
                        
                    } else {
                        
                        let cityError: NSError? = NSError(domain: kErrorDomain, code: 1005, userInfo: ["ErrorString": "No forecast points! \(String(describing: result))"])
                        apiError = cityError
                    }
                }
                
                if let forecastPointsData = forecastJson["list"].array {
                    
                    var parsedPoints: [ForecastPoint] = []
                    for currentPointData in forecastPointsData {
                        
                        let forecastDate = currentPointData["dt_txt"].string
                        let pressure = currentPointData["main"]["pressure"].number?.doubleValue
                        let temperature = currentPointData["main"]["temp"].number?.doubleValue
                        
                        let forecastText = currentPointData["weather"][0]["description"].string
                        
                        let cloudsCover = currentPointData["clouds"]["all"].number?.doubleValue
                        
                        let windDirection = currentPointData["wind"]["deg"].number?.doubleValue
                        let windSpeed = currentPointData["wind"]["speed"].number?.doubleValue
                        
                        if let forecastDate = forecastDate, let pressure = pressure, let temperature = temperature,
                            let forecastText = forecastText, let cloudsCover = cloudsCover,
                            let windDirection = windDirection, let windSpeed = windSpeed {
                            
                            let newForecastPoint = ForecastPoint(dateText: forecastDate, pressure: pressure, temperature: temperature,
                                                                 weatherText: forecastText, clouds: cloudsCover, windDirection: windDirection,
                                                                 windSpeed: windSpeed)
                            
                            parsedPoints.append(newForecastPoint)
                        }
                    }
                    
                    if parsedPoints.count > 0 {
                        
                        forecastPoints = parsedPoints

                    } else {
                        
                        let pointsError: NSError? = NSError(domain: kErrorDomain, code: 1006, userInfo: ["ErrorString": "No forecast points! \(String(describing: result))"])
                        apiError = pointsError
                    }
                }
                
                if let apiError = apiError {
                    
                    DLogWith(message: "Error: \(apiError)")
                    completionBlock(nil, apiError)
                }
                
                if let targetCity = targetCity, let forecastPoints = forecastPoints {
                
                    let obtainedForecast = FiveDaysServiceResponse(city: targetCity, forecastData: forecastPoints)
                    fiveDaysForecast = obtainedForecast
                    
                    completionBlock(fiveDaysForecast, apiError)
                    
                } else {
                    
                    let jsonParsingError: NSError? = NSError(domain: kErrorDomain, code: 1004, userInfo: ["ErrorString": "JSON parsing error! Could not create model objects! \(String(describing: result))"])
                    completionBlock(nil, jsonParsingError)
                }
                
            } else {
                
                let jsonError: NSError? = NSError(domain: kErrorDomain, code: 1003, userInfo: ["ErrorString": "JSON error! This is very wrong! \(String(describing: result))"])
                completionBlock(nil, jsonError)
            }
        }

        // MARK: LINK TO GENERATED API CALL CODE ...
        
        OpenWeatherMap_5Days_API.sendRequestFor(city: city, country: country, forApiKey: kOpenWeatherMapAPIKey, andOnCompletion: transformResponseToModel)
    }
}


