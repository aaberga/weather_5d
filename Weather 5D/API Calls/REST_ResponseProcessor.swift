//
//  REST_ResponseProcessor.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 26/08/2016.
//  Copyright © 2016 iBat Inc. All rights reserved.
//

import Foundation

// MARK: Helper Types

// MARK: REST_ResponseType

/*
let palla = 100...199
let singleDigitNumbers = 0..<10
*/


enum REST_ResponseClass {
    
    case informational          // 100...199
    case success                // 200...299
    case redirection            // 300...399
    case clientError            // 400...499
    case serverError            // 500...599
    
    case undefined              // 0...99 && 599...MaxInt
}


enum REST_ResponseType {
    
    case successWithObjectBody
    case successWithListBody
    case successWithoutBody
    
    case errorWithObjectBody
    case errorWithListBody
    case errorWithoutBody
}


enum REST_ResponseValueType {

    case emptyResponse
    case objectResponse
    case listResponse
}


struct REST_ResponseDescriptor {
    
    let responseClassCode: Int!
    let responseClass: REST_ResponseClass!
    let valueType: REST_ResponseValueType!
    let valueObjectName: String?
}



typealias APICallResponseBlock = (_ result: AnyObject?, _ error: NSError?) -> Void


// MARK: - Classes

class REST_ResponseProcessor: REST_API_Delegate {
    
    // MARK: Properties
    
    var apiCallResponseBlock: APICallResponseBlock? = nil
    var apiErrorDomain: String = "Generic API Error"
    
    
    // MARK: Private Properties
 
    fileprivate var responseCodesTable: [Int: REST_ResponseType] = [:]
    fileprivate var responseActionsTable: [Int: APICallResponseBlock] = [:]
    fileprivate var responseAction: APICallResponseBlock?
   
    
    // MARK: - Methods
    
    func addResponseClass(_ code: Int, withResponseType type: REST_ResponseType) {
        
        self.responseCodesTable[code] = type
    }
    
    func setResponseCall(_ callObject: @escaping APICallResponseBlock) {
        
        self.responseAction = callObject
    }
    
    func setResponseCall(_ callObject: @escaping APICallResponseBlock, forResponseCode code:Int) {
        
        let genericAction = self.responseAction
        
        if let _ = genericAction {
        } else {
            self.responseAction = callObject
        }
        
        self.responseActionsTable[code] = callObject
    }
    
    func receiveCallResults(_ data: Data?, response: URLResponse?, error: Error?) -> Void {
        
        if let returnedError = error {
            
            self.performNetworkErrorProcessing(data, response: response, error: returnedError)
            return
        }
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        let definedResponseClass = self.responseCodesTable[statusCode]
        
        if let definedResponseClass = definedResponseClass {
            
            // We have got an expected code, for which we do have configuration
            self.performSpecificResponseProcessing(statusCode, responseType: definedResponseClass, data: data, response: response, error: error)
            
        } else {
            
            // We have got an unexpected code or a code for which we do not have a specified reaction
            self.performGenericResponseProcessing(statusCode, data: data, response: response, error: error)
        }
    }
    
    
    // MARK: Private Methods
    
    func performNetworkErrorProcessing(_ data: Data?, response: URLResponse?, error: Error?) -> Void {
        
        let genericAction = self.responseAction
        
//        print("Received Error: \(error)")
        
        if let genericAction = genericAction, let error = error {
            
            let error = NSError(domain: self.apiErrorDomain, code: -1, userInfo: ["ErrorData": error])
            genericAction(nil, error)
        }
    }
    
    func performSpecificResponseProcessing(_ responseCode: Int, responseType type: REST_ResponseType, data: Data?, response: URLResponse?, error: Error?) -> Void {
        
        var configuredAction = self.responseActionsTable[responseCode]
        if let _ = configuredAction {
        } else {
            
            if let genericAction = self.responseAction {
                configuredAction = genericAction
            } else {
                return
            }
        }
        
        if let data = data {
            print("Response data: \(String(describing: nsdataToString(data)))")
        }
        
        var responseObject: [String: Any]? = nil
        var responseArray: [Any]? = nil
        var responseError: NSError? = nil
        
        if let configuredAction = configuredAction {
            
            responseObject = nsdataToJSON(data!) as? [String: Any]
            responseArray = nsdataToJSON(data!) as? [Any]            
            responseError = NSError(domain: "WhatError???", code: responseCode, userInfo: ["ErrorData": "to be decided"])

            switch type {
                
            case .successWithObjectBody:

                responseObject = nsdataToJSON(data!) as? [String: Any]
                configuredAction(responseObject as AnyObject?, nil)
                
            case .successWithListBody:
                
                responseArray = nsdataToJSON(data!) as? [Any]
                configuredAction(responseArray as AnyObject?, nil)
               
            case .successWithoutBody:
                configuredAction(nil, nil)
               
            case .errorWithObjectBody:

                responseObject = nsdataToJSON(data!) as? [String: Any]
                responseError = NSError(domain: "WhatError???", code: responseCode, userInfo: ["ErrorData": responseObject!])
                configuredAction(nil, responseError)
                
            case .errorWithListBody:
                responseArray = nsdataToJSON(data!) as? [Any]
                responseError = NSError(domain: "WhatError???", code: responseCode, userInfo: ["ErrorData": responseArray!])
                configuredAction(nil, responseError)
                
              
            case .errorWithoutBody:
                responseError = NSError(domain: "WhatError???", code: responseCode, userInfo: nil)
                configuredAction(nil, responseError)
            }
        }
    }

    func performGenericResponseProcessing(_ responseCode: Int, data: Data?, response: URLResponse?, error: Error?) -> Void {
        
        var configuredAction = self.responseActionsTable[responseCode]
        if let _ = configuredAction {
        } else {
            
            if let genericAction = self.responseAction {
                configuredAction = genericAction
            } else {
                return
            }
        }
        
        let responseObject: [String: Any]? = nsdataToJSON(data!) as? [String: Any]
        let responseArray: [Any]? = nsdataToJSON(data!) as? [Any]

        switch responseCode {
            
        case 200..<299:
            
            if let responseObject = responseObject, let configuredAction = configuredAction {
                
                configuredAction(responseObject as AnyObject?, nil)
            }
            
            if let responseArray = responseArray, let configuredAction = configuredAction {
                
                configuredAction(responseArray as AnyObject?, nil)
            }
           
            
        case 300..<599:
            
            if let responseObject = responseObject, let configuredAction = configuredAction {
                
                let error = NSError(domain: self.apiErrorDomain, code: responseCode, userInfo: ["ErrorData": responseObject])
                configuredAction(nil, error)
            }
            
            if let responseArray = responseArray, let configuredAction = configuredAction {
                
                let error = NSError(domain: self.apiErrorDomain, code: responseCode, userInfo: ["ErrorData": responseArray])
                configuredAction(nil, error)
            }
            
        default:
            break
            
        }
   }
}



// **************************************************************


// MARK: - Generic Helper Functions

// MARK: Convert from NSData to JSON and back

func stringToData(_ string: String) -> Data? {
    
    let data = string.data(using: .utf8)
    
    return data
}

func nsdataToJSON(_ data: Data) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .allowFragments])
    } catch let myJSONError {
        print("nsdataToJSON: \(myJSONError)")
    }
    return nil
}


func jsonToNSData(_ json: AnyObject) -> Data? {
    do {
        return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
    } catch let myJSONError {
        print("jsonToNSData: \(myJSONError)")
    }
    return nil;
}

// MARK: Convert from NSData to String and back

func nsdataToString(_ data: Data) -> NSString? {
    
    let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    return datastring
}

func stringToJSON(_ text: String) -> Any? {
    if let data = text.data(using: String.Encoding.utf8) {
        return nsdataToJSON(data)
    }
    return nil
}

