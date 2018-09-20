//
//  REST_API.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2016 iBat Inc. All rights reserved.
//


import Foundation

class GenericRequestController: DataService {
    
    // MARK: Properties
    
    
    // MARK: Private Properties
    
    private var configManager: REST_API_ConfigManager!
    private var restAPI: REST_API!
    private var responseProcessor: REST_ResponseProcessor!
    
    
    // MARK: Object Life Time
    
    init(configResource filename: String) {
        
        self.configManager = REST_API_ConfigManager(resourceName: filename)
        self.restAPI = REST_API()
        self.responseProcessor = REST_ResponseProcessor()
    }
    
    func setConfiguration(manager: REST_API_ConfigManager) {
        
        self.configManager = manager
    }
    
    func setEndpoint(manager: REST_API) {
        
        self.restAPI = manager
    }
    
    func setResponseProcessor(processor: REST_ResponseProcessor) {
        
        self.responseProcessor = processor
    }
    
    
    // MARK: Helper Interface
    
    func prepareAPIDataFor(apiOperationID operationID: String) -> (protocol: API_Protocols, address: String, baseURL: String, operationURL: String, callType: REST_Methods)? {
        
        var resultRecord: (protocol: API_Protocols, address: String, baseURL: String, operationURL: String, callType: REST_Methods)? = nil
        let actionURL = configManager.restCallPathFor(operationID: operationID)
        
        if let configManager = self.configManager, let actionURL = actionURL {
            
            let hostProtocol = configManager.restCallProtocol()
            let hostAddress = configManager.host
            let baseURL = configManager.restCallBaseURL()
            let callType = configManager.restCallType(forPath: actionURL)
            
            if let hostProtocol = hostProtocol, let callType = callType {
                
                resultRecord =  (protocol: hostProtocol, address: hostAddress, baseURL: baseURL, operationURL: actionURL, callType: callType)
            }
        }
        
        return resultRecord
    }
    
    func prepareAPIDataFor(apiOperationSummary summary: String) -> (protocol: API_Protocols, address: String, baseURL: String, operationURL: String, callType: REST_Methods)? {
        
        var resultRecord: (protocol: API_Protocols, address: String, baseURL: String, operationURL: String, callType: REST_Methods)? = nil
        let actionURL = configManager.restCallPathFor(operationSummary: summary)
        
        if let configManager = self.configManager, let actionURL = actionURL {
            
            let hostProtocol = configManager.restCallProtocol()
            let hostAddress = configManager.host
            let baseURL = configManager.restCallBaseURL()
            let callType = configManager.restCallType(forPath: actionURL)
            
            if let hostProtocol = hostProtocol, let callType = callType {
                
                resultRecord =  (protocol: hostProtocol, address: hostAddress, baseURL: baseURL, operationURL: actionURL, callType: callType)
            }
        }
        
        return resultRecord
    }
    
    func prepareResponseProcessor(responseData: [REST_ResponseDescriptor]) {
        
        if let responseProcessor = self.responseProcessor {
            
            for currResponseDataItem in responseData {
                
                let responseCode = currResponseDataItem.responseClassCode!
                
                if currResponseDataItem.responseClass == .success {
                    
                    switch currResponseDataItem.valueType! {
                        
                    case REST_ResponseValueType.emptyResponse:
                        responseProcessor.addResponseClass(responseCode, withResponseType: .successWithoutBody)
                        
                    case REST_ResponseValueType.listResponse:
                        responseProcessor.addResponseClass(responseCode, withResponseType: .successWithListBody)
                        
                    case REST_ResponseValueType.objectResponse:
                        responseProcessor.addResponseClass(responseCode, withResponseType: .successWithObjectBody)
                    }
                }
                
                if currResponseDataItem.responseClass == .serverError || currResponseDataItem.responseClass == .clientError {
                    
                    switch currResponseDataItem.valueType! {
                        
                    case REST_ResponseValueType.emptyResponse:
                        responseProcessor.addResponseClass(responseCode, withResponseType: .errorWithoutBody)
                        
                    case REST_ResponseValueType.listResponse:
                        responseProcessor.addResponseClass(responseCode, withResponseType: .errorWithObjectBody)
                        
                    case REST_ResponseValueType.objectResponse:
                        responseProcessor.addResponseClass(responseCode, withResponseType: .errorWithObjectBody)
                    }
                }
            }
        }
    }
    
    func prepareCallParameters(apiPath pathString: String, parameters: [AnyHashable: Any]?) -> (queryParameters: [AnyHashable: Any]?, pathParameters: [AnyHashable: Any]?, bodyParameters: [AnyHashable: Any]?)? {
        
        if let configManager = self.configManager, let parameters = parameters {
            
            let actionParameterNames = configManager.listParameters(forPath: pathString)
            
            var pathParamNames: [String] = []
            var queryParamNames: [String] = []
            var bodyParamNames: [String] = []
            
            var pathParameters: [AnyHashable: Any] = [:]
            var queryParameters: [AnyHashable: Any] = [:]
            var bodyParameters: [AnyHashable: Any] = [:]
            
            if let actionParameterNames = actionParameterNames {
                
                for currentParam in actionParameterNames {
                    
                    let paramPosition = configManager.position(ofParameter: currentParam, atPath: pathString)!
                    
                    switch paramPosition {
                        
                    case .path:
                        pathParamNames.append(currentParam)
                        
                    case .query:
                        queryParamNames.append(currentParam)
                        
                    case .body:
                        bodyParamNames.append(currentParam)
                    }
                }
                
                for currentParam in pathParamNames {
                    
                    // Path Parameters are by their nature MANDATED (or the URL would be invalid!!)
                    
                    if parameters.keys.contains(currentParam) {
                        
                        pathParameters[currentParam] = parameters[currentParam]!
                        
                    } else {
                        
                        // Houston, we have a problem!!
                    }
                }
                
                for currentParam in queryParamNames {
                    
                    // Path Parameters can be MANDATED or OPTIONAL
                    let currentParamMandated = configManager.isRequired(ofParameter: currentParam, atPath: pathString)!
                    
                    if parameters.keys.contains(currentParam) {
                        
                        queryParameters[currentParam] = parameters[currentParam]!
                        
                    } else if currentParamMandated {
                        
                        // Houston, we have a problem!!
                    }
                }
                
                for currentParam in bodyParamNames {
                    
                    // Body Parameters can be MANDATED or OPTIONAL
                    let currentParamMandated = configManager.isRequired(ofParameter: currentParam, atPath: pathString)!
                    
                    if parameters.keys.contains(currentParam) {
                        
                        bodyParameters[currentParam] = parameters[currentParam]!
                        
                    } else if currentParamMandated {
                        
                        // Houston, we have a problem!!
                    }
                }
            }
            
            return (queryParameters: queryParameters, pathParameters: pathParameters, bodyParameters: bodyParameters)
        }
        
        return nil
    }
    
    
    // MARK: Generic Interface
    
    func obtainEntityFor(key: String, withParameters passedData: [String : Any]?, andOnCompletion completionBlock: @escaping (Any?, Error?) -> Void) {
        
        let basicAPIConfig = self.prepareAPIDataFor(apiOperationID: key)
        
        var callHeaders: [String: String]?
        var queryParameters: [AnyHashable: Any]?
        var pathParameters: [AnyHashable: Any]?
        var bodyParameters: [AnyHashable: Any]?
        
        if let basicAPIConfig = basicAPIConfig {
            
            let apiResponseData = self.configManager.restResponseData(for: basicAPIConfig.operationURL)
            
            if let apiResponseData = apiResponseData {
                
                self.prepareResponseProcessor(responseData: apiResponseData)
                
            } else {
                
                // call completion block with custom error ...
                return
            }
            
        } else {
            
            // call completion block with custom error ...
            return
        }
        
        if let responseProcessor = self.responseProcessor, let apiCallObject = self.restAPI, let basicAPIConfig = basicAPIConfig {
            
            responseProcessor.apiErrorDomain = "OpenWeatherMap"
            responseProcessor.apiCallResponseBlock = completionBlock
            
            apiCallObject.delegate = responseProcessor
            responseProcessor.setResponseCall(completionBlock)
            
            let parametersSet = self.prepareCallParameters(apiPath: basicAPIConfig.operationURL, parameters: passedData)
            let userToken = passedData?["kUserToken"] as? String
            
            if let parametersSet = parametersSet, let userToken = userToken {
                
                pathParameters = parametersSet.pathParameters
                queryParameters = parametersSet.queryParameters
                bodyParameters = parametersSet.bodyParameters
                
                if (bodyParameters?.count)! > 0 {
                    print("AAArgh!!!")
                }
                
                let hostURL = String(format: "%@%@", basicAPIConfig.address, basicAPIConfig.baseURL)
                let apiURL = String(basicAPIConfig.operationURL.dropFirst())
                let parametrizedURL = self.configManager.decorate(urlPath: apiURL, withParams: pathParameters!)
                callHeaders = self.configManager.getHeaders(for: apiURL, authToken: userToken)
                
                let callType = basicAPIConfig.callType
                
                switch callType {
                    
                case .DELETE:
                    
                    let nilBlock = { (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
                    }
                    
                    apiCallObject.doDELETE(withProtocol: basicAPIConfig.protocol, URLRootString: hostURL, URLActionString: parametrizedURL, andHeadersDictionary: callHeaders!, andURLParamsDictionary: queryParameters as! [String : String]?, withCompletionBlock: nilBlock)
                    
                case .GET:
                    
                    apiCallObject.doGET(withProtocol: basicAPIConfig.protocol, URLRootString: hostURL, URLActionString: parametrizedURL, andHeadersDictionary: callHeaders!, andURLParamsDictionary: queryParameters as! [String : String]?)
                default:
                    return
                }
            }
        }
    }
    
    func sendData(_ data: AnyObject, forKey key:String, type: String, withParameters passedData: [String: Any]?, andCompletion completionBlock: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        
        let basicAPIConfig = self.prepareAPIDataFor(apiOperationID: key)
        
        var callHeaders: [String: String]?
        var queryParameters: [AnyHashable: Any]?
        var pathParameters: [AnyHashable: Any]?
        var bodyParameters: [AnyHashable: Any]?
        
        var extendedData: [String: Any]? = [:]
        let dataAsDict = data as? [String: Any]
        
        if let dataAsDict = dataAsDict{
            extendedData?.merge(dataAsDict, uniquingKeysWith: { (first, _) in first })
        }
        if let passedData = passedData{
            extendedData?.merge(passedData, uniquingKeysWith: { (first, _) in first })
        }
        
        //print("Extended Data: \(extendedData)")
        
        if let basicAPIConfig = basicAPIConfig {
            
            let apiResponseData = self.configManager.restResponseData(for: basicAPIConfig.operationURL)
            
            if let apiResponseData = apiResponseData {
                
                self.prepareResponseProcessor(responseData: apiResponseData)
                
            } else {
                
                // call completion block with custom error ...
                return
            }
            
        } else {
            
            // call completion block with custom error ...
            return
        }
        
        if let responseProcessor = self.responseProcessor, let apiCallObject = self.restAPI, let basicAPIConfig = basicAPIConfig {
            
            responseProcessor.apiErrorDomain = "OpenWeatherMap"
            responseProcessor.apiCallResponseBlock = completionBlock
            
            apiCallObject.delegate = responseProcessor
            responseProcessor.setResponseCall(completionBlock)
            
            let parametersSet = self.prepareCallParameters(apiPath: basicAPIConfig.operationURL, parameters: extendedData)
            let userToken = passedData?["kUserToken"] as? String
            
            if let parametersSet = parametersSet {
                
                //                print("parametersSet: \(parametersSet)")
                pathParameters = parametersSet.pathParameters
                queryParameters = parametersSet.queryParameters
                bodyParameters = [:]
                let bodyParametersComponents = parametersSet.bodyParameters
                
                let currentDataBlobNames = bodyParametersComponents?.keys
                if let currentDataBlobNames = currentDataBlobNames {
                    
                    for currentDataBlobName in currentDataBlobNames {
                        
                        let currentBlob = bodyParametersComponents?[currentDataBlobName] as? [String: Any]
                        
                        if let currentBlob = currentBlob {
                           bodyParameters?.merge(currentBlob, uniquingKeysWith: { (first, _) in first })
                        }
                    }
                }
                //                print("Body: \(bodyParameters)")
                
                if (queryParameters?.count)! > 0 {
                    print("AAArgh!!!")
                }
                
                let hostURL = String(format: "%@%@", basicAPIConfig.address, basicAPIConfig.baseURL)
                let apiURL = String(basicAPIConfig.operationURL.dropFirst())
                let parametrizedURL = self.configManager.decorate(urlPath: apiURL, withParams: pathParameters!)
                callHeaders = self.configManager.getHeaders(for: apiURL, authToken: userToken)
                
                let callType = basicAPIConfig.callType
                
                switch callType {
                    
                case .PUT:
                    
                    apiCallObject.doPUT(withProtocol: basicAPIConfig.protocol, URLRootString: hostURL, URLActionString: parametrizedURL, andHeadersDictionary: callHeaders!, andBodyParamsDictionary: bodyParameters as! [String : AnyObject]?)
                    
                case .POST:
                    
                    apiCallObject.doPOST(withProtocol: basicAPIConfig.protocol, URLRootString: hostURL, URLActionString: parametrizedURL, andHeadersDictionary: callHeaders!, andBodyParamsDictionary: bodyParameters as! [String : AnyObject]?)
                    
                default:
                    return
                }
            }
        }
    }
}





