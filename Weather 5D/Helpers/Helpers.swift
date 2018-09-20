//
//  Helpers.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 20/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import Foundation
import SwiftyJSON


class Helpers {
    
    class func readJSON(from fileName: String, ofType type: String = "json") -> JSON? {
        
        if let filePath = Bundle.main.path(forResource: fileName, ofType: type),
            let data = NSData(contentsOfFile: filePath) {
            do {

               let jsonData = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
               return JSON(jsonData)
            }
            catch {
                
                //Handle error
                return nil
            }
        }
        return nil
    }
}
