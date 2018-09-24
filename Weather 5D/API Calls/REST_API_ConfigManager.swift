//
//  REST_API_ConfigManager.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 14/11/2016.
//  Copyright © 2016 iBat. All rights reserved.
//

import Foundation


import Regex
import SwiftyJSON




class REST_API_ConfigManager {
    
    // MARK: Properties
    
    var configResource: String?
    var configData: [AnyHashable: Any]?
    
    
    // MARK: Convenience Accessors
    
    var apiProtocol: String {
        
        get {
            
            if let configData = self.configData {
                
                return configData["protocol"] as! String
                
            } else {
                
                return ""
            }
        }
    }
    
    var host: String {
        
        get {
            
            if let configData = self.configData {
                
                return configData["host"] as! String
                
            } else {
                
                return ""
            }
        }
    }
    
    var basePath: String {
        
        get {
            
            if let configData = self.configData {
                
                return configData["basePath"] as! String
                
            } else {
                
                return ""
            }
        }
    }
    
    var definitions: [AnyHashable: Any]? {
        
        get {
            
            if let configData = self.configData {
                
                return configData["definitions"] as? [AnyHashable: Any]
                
            } else {
                
                return nil
            }
        }
    }
    
    var paths: [AnyHashable: Any]? {
        
        get {
            
            if let configData = self.configData {
                
                return configData["paths"] as? [AnyHashable: Any]
                
            } else {
                
                return nil
            }
        }
    }
    
    // MARK: Life Cycle Methods
    
    init(resourceName fileName: String) {
        
        let resourceReader = RestAPIConfigReader()
        
        resourceReader.loadDataFile("OpenWeatherMapAPI_metadata")

        let configData = resourceReader.configData
        if let configData = configData {
            
            self.configData = configData as? [AnyHashable : Any]
        }
    }
    
    // MARK: Interface Methods
    
    func getHeaders(for pathString: String, authToken: String?) -> [String: String] {
       
        if let authToken = authToken {
            
            let tokenString = String(format: "appid %@", authToken)
            let resultHeaders = ["Content-Type": "application/json", "Authorization" : tokenString]
        
            return resultHeaders
            
        } else {
            
            return ["Content-Type": "application/json"]
        }
    }
    
    func pathData(forURL key: String) ->  [AnyHashable: Any]? {
        
        return self.paths?[key] as! [AnyHashable : Any]?
    }
    
    func restCallProtocol() ->  API_Protocols? {
        
        let callProtocolString = self.apiProtocol
        return API_Protocols(rawValue: callProtocolString)
    }
    
    func restCallType(forPath key: String) -> REST_Methods? {
        
        let pathData = self.pathData(forURL: key)
        
        if let pathData = pathData {
            
            let callTypeString = pathData.keys.first! as! String
            let callMethod = REST_Methods(rawValue: callTypeString.uppercased())
            
            return callMethod
            
        } else {
            
            return nil
        }
    }
    
    func restCallBaseURL() -> String {
        
        return self.basePath
    }
    
    func restCallPathFor(operationSummary summary: String) -> String? {
        
        var foundActionURL: String? = nil
        
        let callDefinitionData = self.paths
        let jsonCallDefinitions = JSON(callDefinitionData!).dictionaryValue
        
        let targetDefinitionData = jsonCallDefinitions.filter({(key: String, value: JSON) -> Bool in
            
            let firstKey = value.dictionaryValue.keys.first!
            let pathDef = value.dictionaryValue[firstKey]!.dictionaryValue
            
            let operationSummary = pathDef["summary"]?.string
            
            if let operationSummary = operationSummary {
                
                if operationSummary == summary {
                    return true
                }
            }
            return false
        })
        
        foundActionURL = targetDefinitionData.first!.key
        return foundActionURL
    }
    
    func restCallPathFor(operationID id: String) -> String? {
        
        var foundActionURL: String? = nil
        
        let callDefinitionData = self.paths
        let jsonCallDefinitions = JSON(callDefinitionData!).dictionaryValue
        
        let targetDefinitionData = jsonCallDefinitions.filter({(key: String, value: JSON) -> Bool in
            
                let firstKey = value.dictionaryValue.keys.first!
                let pathDef = value.dictionaryValue[firstKey]!.dictionaryValue
            
                let operationID = pathDef["operationId"]?.string
            
                if let operationID = operationID {
                    
                    if operationID == id {
                        return true
                    }
                }
                return false
            })
        
        foundActionURL = targetDefinitionData.first!.key 
        return foundActionURL
    }
    
    func restResponseData(for path: String) -> [REST_ResponseDescriptor]? {
        
        //print("\nCALL: \(path)")
        var responseDescriptors = [REST_ResponseDescriptor]()
        
        let callDefinitionData = self.paths
        let jsonCallDefinitions = JSON(callDefinitionData!).dictionaryValue
        
        let targetDefData = jsonCallDefinitions[path]?.dictionaryValue
        let currentDefDataKey = targetDefData!.keys.first!
        let pathDefinitionData = targetDefData?[currentDefDataKey]

        if let pathDefinitionData = pathDefinitionData {
            
            let rawResponses = pathDefinitionData.dictionaryValue["responses"]?.dictionaryValue
    
            if let rawResponses = rawResponses {
            
                for currentResponseKey in rawResponses.keys.sorted() {
                    
                    let responseDataDef = rawResponses[currentResponseKey]?.dictionaryValue
                    
                    if let responseDataDef = responseDataDef {
                        
                        var responseClass: REST_ResponseClass!
                        let responseClassCode = Int(currentResponseKey)!
                        var responseValueType: REST_ResponseValueType!
                        var responseObjectClassName: String!
                        
                        switch responseClassCode {
                            
                            case 100...199:
                                responseClass = .informational

                            case 200...299:
                                responseClass = .success

                            case 300...399:
                                responseClass = .redirection

                            case 400...499:
                                  responseClass = .clientError

                            case 500...599:
                                responseClass = .serverError
                            
                            default:
                                responseClass = .undefined
                        }
                        
                        if responseDataDef.keys.count == 1 {
                            
                            responseValueType = .emptyResponse
                            //print("\(currentResponseKey) - No Obj/List: empty response")
                            
                            let currentDescriptor = REST_ResponseDescriptor(responseClassCode: responseClassCode, responseClass: responseClass, valueType: responseValueType, valueObjectName: nil)
                            responseDescriptors.append(currentDescriptor)

                        } else {
                            
                            if responseDataDef.keys.contains("schema") {
                                
                                let responseDataSchema = responseDataDef["schema"]!.dictionaryValue
                                
                                if responseDataSchema.keys.count == 1 {
                                    
                                    responseValueType = .objectResponse
                                    
                                    //print("Obj: \(responseDataDef)")
                                    let rawObjNameString = responseDataDef["schema"]?["$ref"].stringValue
                                    if let rawObjNameString = rawObjNameString {
                                        
                                        // split on "/" and get last item!
                                        let nsString = NSString(format: "%@", rawObjNameString)
                                        responseObjectClassName = nsString.components(separatedBy: "/").last!
                                        //print("\(currentResponseKey) - Dict Obj Def: \(responseObjectClassName!)")
                                        let currentDescriptor = REST_ResponseDescriptor(responseClassCode: responseClassCode, responseClass: responseClass, valueType: responseValueType, valueObjectName: responseObjectClassName)
                                        
                                        responseDescriptors.append(currentDescriptor)
                                    }

                                } else {
                                    
                                    let items = responseDataSchema["items"]?.dictionaryValue
                                    if let items = items {

                                        responseValueType = .listResponse

                                        var rawObjNameString = items["$ref"]?.stringValue
                                        if let rawObjNameString = rawObjNameString {
                                            
                                            // split on "/" and get last item!
                                            let nsString = NSString(format: "%@", rawObjNameString)
                                            responseObjectClassName = nsString.components(separatedBy: "/").last!
                                            //print("\(currentResponseKey) - Dict Obj Def: \(responseObjectClassName!)")
                                            
                                            let currentDescriptor = REST_ResponseDescriptor(responseClassCode: responseClassCode, responseClass: responseClass, valueType: responseValueType, valueObjectName: responseObjectClassName)
                                            
                                            responseDescriptors.append(currentDescriptor)
                                            
                                        } else {
                                            
                                            rawObjNameString = items["type"]?.stringValue
                                            if let rawObjNameString = rawObjNameString {
                                                
                                                //print("\(currentResponseKey) - Dict Obj Def: \(rawObjNameString)")
                                                let currentDescriptor = REST_ResponseDescriptor(responseClassCode: responseClassCode, responseClass: responseClass, valueType: responseValueType, valueObjectName: rawObjNameString)
                                                
                                                responseDescriptors.append(currentDescriptor)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
        
        return responseDescriptors
    }
    
    func definitionForKey(key theKey: String) ->  [AnyHashable: Any]? {
        
        return self.definitions?[theKey] as! [AnyHashable : Any]?
    }
    
    func listAllPaths() -> [String]? {
        
        let pathData = self.paths
        let jsonData = JSON(pathData!).dictionaryValue as NSDictionary

        let allCallPaths = jsonData.allKeys as? [String]
        
        return allCallPaths
    }
    
    func listParameters(ofKind kind: REST_ParameterKind = .allParams, forPath path: String) -> [String]? {
        
        var foundParameters: [String]? = nil
        
        let pathData = self.pathData(forURL: path)!
        let jsonData = JSON(pathData)
        
        let callType = pathData.keys.first! as! String
        
        let parameters = jsonData[callType]["parameters"].arrayValue
        
        switch kind {
            
        case .allParams:
            foundParameters = parameters.map({$0["name"].stringValue})
            
        case .mandatoryParams:
            
            let parametersData = parameters.filter({$0["required"].intValue == 1})
            foundParameters = parametersData.map( {$0["name"].stringValue} )
            
        case .optionalParams:
            let parametersData = parameters.filter { $0["required"].intValue == 0 }
            foundParameters = parametersData.map({$0["name"].stringValue})
        }
        
        return foundParameters
    }
    
    func type(ofParameter parameter: String, atPath path: String) -> REST_ParameterType? {
        
        var foundType: REST_ParameterType?
        
        let pathData = self.pathData(forURL: path)!
        let jsonData = JSON(pathData)
        
        let callType = pathData.keys.first! as! String
        
        let parameters = jsonData[callType]["parameters"].arrayValue
        let parametersData = parameters.filter { $0["name"].stringValue == parameter }
        let typeStrings = parametersData.map({$0["type"].stringValue})

        let typeString = typeStrings.first
        if let typeString = typeString {
            foundType = REST_ParameterType(rawValue: typeString)
        }
        return foundType
    }
    
    func isRequired(ofParameter parameter: String, atPath path: String) -> Bool? {
        
        var isRequired: Bool? = false
        
        let pathData = self.pathData(forURL: path)!
        let jsonData = JSON(pathData)
        
        let callType = pathData.keys.first! as! String
        
        let parameters = jsonData[callType]["parameters"].arrayValue
        let parametersData = parameters.filter { $0["name"].stringValue == parameter }.first?.dictionaryValue

        if let parametersData = parametersData {
            
            let requiredValue = parametersData["required"]?.bool
            
            if let requiredValue = requiredValue {
                
                isRequired = requiredValue
            }
        }
        return isRequired
    }
    
    func position(ofParameter parameter: String, atPath path: String) -> REST_ParameterPosition? {
        
        var foundPosition: REST_ParameterPosition?
        
        let pathData = self.pathData(forURL: path)!
        let jsonData = JSON(pathData)
        
        let callType = pathData.keys.first! as! String
        
        let parameters = jsonData[callType]["parameters"].arrayValue
        let parametersData = parameters.filter { $0["name"].stringValue == parameter }
        let positionStrings = parametersData.map({$0["in"].stringValue})
        
        let positionString = positionStrings.first
        if let positionString = positionString {
            foundPosition = REST_ParameterPosition(rawValue: positionString)
        }
        return foundPosition
    }
    
    func validate(paramsDict dict: [AnyHashable: Any], forPath path: String) -> Bool {
        
        var dictIsValid = true
        
        let dictKeys = dict.keys
        let mandatedKeys = self.listParameters(ofKind: .mandatoryParams, forPath: path)
        
        if let mandatedKeys = mandatedKeys {
            for currMandatoryKey in mandatedKeys {
                
                if !dictKeys.contains(currMandatoryKey) {
                    dictIsValid = false
                }
            }
        }
        
        let allKeys = self.listParameters(ofKind: .allParams, forPath: path)
        
        if let allKeys = allKeys {
            
            for currDictKey in dictKeys {
                
                if !allKeys.contains(currDictKey as! String) {
                    dictIsValid = false
                }
            }
        }
        
        // Check formats ..., too
        
        for currentParamName in dictKeys {
            
            let currentKeyType = self.type(ofParameter: currentParamName as! String, atPath: path)
            
            //print("Param: \(currentParamName as! String) - Type: \(currentKeyType?.rawValue)")
            //print("Param: \(currentParamName as! String) - Value: \(dict[currentParamName])")

            
            if let currentKeyType = currentKeyType {
                
                switch currentKeyType {
                    
                case .APIKey:
                    let value = dict[currentParamName] as? String
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                    
                case .Array:
                    let value = dict[currentParamName] as? [Any]
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                    
                case .Boolean:
                    let value = dict[currentParamName] as? Bool
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                    
                case .Integer:
                    let value = dict[currentParamName] as? Int
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                    
                case .Number:
                    let value = dict[currentParamName] as? Float
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                    
                case .Object:
                    let value = dict[currentParamName] as? [AnyHashable: Any]
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                    
                case .String:
                    let value = dict[currentParamName] as? String
                    if let _ = value {} else {
                        dictIsValid = false
                    }
                }
                
            } else {
                
                dictIsValid = false
            }
        }
        
        return dictIsValid
    }
    
    func decorate(url urlString: String, withParams paramsDict: [AnyHashable: Any]) -> String {
        
        var decoratedURLString: String = urlString
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        
        let nsURL = URL(string: escapedString!)
        
        if let nsURL = nsURL {
            
            let decoratedURL = nsURL.URLByReplacingPathParameters(paramsDict)
            
            decoratedURLString = decoratedURL.absoluteString
        }
        
        return decoratedURLString
    }
    
    func decorate(urlPath urlString: String, withParams paramsDict: [AnyHashable: Any]) -> String {
        
        var decoratedURLString: String = urlString
        
        for currenParamKey in paramsDict.keys {
            
            let keyString = currenParamKey as? String
            var partialURLString = decoratedURLString
            
            if let keyString = keyString {
                
                let value = paramsDict[keyString]
                
                if let value = value {
                    
                    let valueString = String(describing: value)
                    let keyTarget = String(format: "\\{%@\\}", keyString)
                    
                    let updatedURLString = keyTarget.r?.replaceAll(in: partialURLString, with: valueString)
                    
                    if let updatedURLString = updatedURLString {
                        
                        partialURLString = updatedURLString
                    }
                }
            }
            
            decoratedURLString = partialURLString
        }
        
        return decoratedURLString
    }
}
