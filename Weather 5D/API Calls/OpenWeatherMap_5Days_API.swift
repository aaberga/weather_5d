//
//  OpenWeatherMap_5Days_API.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 
 For a quick turnaround this source code file actually originates from a template-based code generation tool inside the macOS Paw app.
 
 Code edited (@AAB) to fit in application architecture.
 
 */

// API Key: "5f0f94b44eab3e3040fe2750f430b8bd"


private let kAPIURLString = "https://api.openweathermap.org/data/2.5/forecast"
private let kAPIMode = "json"


// Convenience: Template Generated Code (Paw macOS App), that was adapted to fit in Coordinator/Service App Architecture

class OpenWeatherMap_5Days_API {
    
    static func sendRequestFor(city: String, country countryCode: String? = nil, forApiKey apiKey: String, andOnCompletion completionBlock: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        /* Configure session, choose between:
           * defaultSessionConfiguration
           * ephemeralSessionConfiguration
           * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
           Request (GET https://api.openweathermap.org/data/2.5/forecast)
         */

        guard var URL = URL(string: kAPIURLString) else {return}
        
        var targetCityString = city
        if let countryCode = countryCode {
            targetCityString = String(format: "%@,%@", city, countryCode)
        }
        
        let URLParams = [
            "q": targetCityString,
            "mode": kAPIMode,
            "appid": apiKey,
        ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if (error == nil) {
                
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
//                DLogWith(message: "URL Session Task Succeeded: HTTP \(statusCode)")
                
                if let data = data {
                    if let json = try? JSON(data: data) {
                        completionBlock(json, error)
                    } else {
                        
                        let jsonError = NSError(domain: "OpenWeatherError", code: 1001, userInfo: ["StatusCode": statusCode])
                        completionBlock(nil, jsonError)
                    }
                }
            }
            else {
                
                // Failure
//                DLogWith(message: "URL Session Task Failed: \(error!.localizedDescription)")
                
                if let error = error {
                    completionBlock(nil, error)
                }
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

// Convenience: Template Generated Code (Paw macOS App)

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
    */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
    */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}


