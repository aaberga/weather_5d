//
//  RestAPIConfigReader.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 25/04/2016.
//  Copyright © 2016 iBat Inc. All rights reserved.
//

import Foundation


class RestAPIConfigReader {
    
    var configFilePath: String?
    var targetFileName: String?
    
    var configData: NSDictionary?
    
    func loadDataFile(_ filename: String) {
    
        let path = Bundle.main.path(forResource: filename, ofType: "plist")
        if let path = path {
            
            let readDict = NSDictionary(contentsOfFile: path)
            if let dataDict = readDict {
                self.configData = dataDict
            }
        }
    }
    
    func getDataProperty(key targetKey:String) -> AnyObject? {
        
        var result: AnyObject?
        
        result = self.configData?.object(forKey: targetKey) as AnyObject?
        
        return result
    }
    
    
    func getAllData() -> NSDictionary? {
        
        return configData
    }
}
