//
//  ServiceResponse.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 24/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import Foundation


struct FiveDaysServiceResponse {
    
    let city: City
    let forecastData: [ForecastPoint]
}
