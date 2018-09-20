//
//  REST_API.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 17/05/2016.
//  Copyright © 2016 iBat Inc. All rights reserved.
//

import Foundation

enum API_Protocols: String {
    
    case http = "http"
    case https = "https"
}


enum REST_Methods: String {
    
    case HEAD = "HEAD"
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}


enum REST_ParameterKind {
    
    case allParams
    case mandatoryParams
    case optionalParams
}


enum REST_CallType: String {
    
    case HEAD = "head"
    case GET = "get"
    case POST = "post"
    case PUT = "put"
    case DELETE = "delete"
    case PATCH = "patch"
}


enum REST_ParameterPosition: String {
    
    case path = "path"
    case query = "query"
    case body = "body"
}


enum REST_ParameterType: String {
    
    case APIKey = "apiKey"
    case Array = "array"
    case Boolean = "boolean"
    case Integer = "integer"
    case Number = "number"
    case Object = "object"
    case String = "string"
}


enum REST_ParameterFormats: String {
    
    case Int32 = "int32"
    case Int64 = "int64"
    case Float = "float"
    case Date = "date-time"
}


protocol REST_API_Delegate {
    
    func receiveCallResults(_ data: Data?, response: URLResponse?, error: Error?) -> Void
}

class REST_API {
    
    var delegate: REST_API_Delegate?
    
    func doGET(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                            andHeadersDictionary headers: [String: String]?, andURLParamsDictionary urlParams: [String: String]? ) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Get Items for User (GET targetProtocol://URLRootString/URLActionString )
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        //print("GET call: \(urlString)")
        
        guard var URL = URL(string: urlString) else { return }
        
        if let URLParams = urlParams {
            URL = URL.URLByAppendingQueryParameters(URLParams)
        }
        //print("GET call: \(URL.absoluteString)")

        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.GET.rawValue
        
        // Headers
        
        if let headers = headers {
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        /* Start a new Task */
        
        if let delegate = self.delegate {
            
            let task = session.dataTask(with: request, completionHandler: delegate.receiveCallResults)
            task.resume()
        }
    }
    
    func doGET(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                            andHeadersDictionary headers: [String: String]?, andURLParamsDictionary urlParams: [String: String]?, withCompletionBlock completionBlock: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Get Items for User (GET targetProtocol://URLRootString/URLActionString )
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        
        guard var URL = URL(string: urlString) else { return }
        
        if let URLParams = urlParams {
            URL = URL.URLByAppendingQueryParameters(URLParams)
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.GET.rawValue
        
        // Headers
        
        if let headers = headers {
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: completionBlock)   // as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
    }
    
    func doPUT(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                            andHeadersDictionary headers: [String: String]?, andBodyParamsDictionary bodyParams: [String: Any]?) {
    }
    
    func doPUT(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                            andHeadersDictionary headers: [String: String]?, andBodyParamsDictionary bodyParams: [String: Any]?, withCompletionBlock completionBlock: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Update User Preferences (PUT http://sampleHost:8080/rest/userpreferences/update/1)
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        
        guard let URL = URL(string: urlString) else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.PUT.rawValue
        
        // Headers
        
        if let headers = headers {
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        // JSON Body
        
        if let bodyParams = bodyParams {
            
            let bodyObject: [String: Any] = bodyParams
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: completionBlock)
        task.resume()
    }
    
    func doPOST(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                             andHeadersDictionary headers: [String: String]?, andBodyParamsDictionary bodyParams: [String: Any]?, withCompletionBlock completionBlock: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        /* Configure session, choose between:
         
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Add User Preferences (POST http://sampleHost:8080/rest/userpreferences/add)
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        
        guard let URL = URL(string: urlString) else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.POST.rawValue
        
        // Headers
        
        if let headers = headers {
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
                
                print("Key: \(headerKey) -  Value: \(headerValue)")
            }
        }
        
        // JSON Body
        
        if let bodyParams = bodyParams {
            
            let bodyObject: [String: Any] = bodyParams
//            print("POST body:")
//
//            for bodyKey in bodyObject.keys {
//                let bodyValue = bodyObject[bodyKey]!
//                print("Key: \(bodyKey) -  Value: \(bodyValue)")
//            }
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        }
        
        /* Start a new Task */
        
        let task = session.dataTask(with: request, completionHandler: completionBlock)   // as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
        
//        print("Headers: \(headers)")
//        print("Body Params: \(bodyParams!)")
//        print("Request Body: \(nsdataToString(request.HTTPBody!)!)")
        
//        print("now done...")
    }
    
    func doPOST(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                             andHeadersDictionary headers: [String: String]?, andBodyParamsDictionary bodyParams: [String: Any]? ) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Add User Preferences (POST )
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        //print("POST url: \(urlString)")
        
        guard let URL = URL(string: urlString) else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.POST.rawValue
        
        // Headers
        
        if let headers = headers {
            
            //            print("POST headers:")
            
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                //                print("Key: \(headerKey) -  Value: \(headerValue)")
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        // JSON Body
        
        if let bodyParams = bodyParams {
            
            let bodyObject: [String: Any] = bodyParams
            //            print("POST body:")
            //
            //            for bodyKey in bodyObject.keys {
            //                let bodyValue = bodyObject[bodyKey]!
            //                print("Key: \(bodyKey) -  Value: \(bodyValue)")
            //            }
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
            //            print("JSON: \(nsdataToString(request.HTTPBody!)!)")
        }
        
        /* Start a new Task */
        
        if let delegate = self.delegate {
            
            let task = session.dataTask(with: request, completionHandler: delegate.receiveCallResults)
            task.resume()
        }
    }
    
    func doDELETE(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                               andHeadersDictionary headers: [String: String]?, andURLParamsDictionary urlParams: [String: String]?, withCompletionBlock completionBlock: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Get Items for User (GET targetProtocol://URLRootString/URLActionString )
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        
        guard var URL = URL(string: urlString) else { return }
        
        if let URLParams = urlParams {
            URL = URL.URLByAppendingQueryParameters(URLParams)
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.DELETE.rawValue
        
        // Headers
        
        if let headers = headers {
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: completionBlock)
        task.resume()
    }
    
    func doPATCH(withProtocol targetProtocol: API_Protocols, URLRootString: String, URLActionString: String,
                              andHeadersDictionary headers: [String: String]?, andBodyParamsDictionary bodyParams: [String: Any]?, withCompletionBlock completionBlock: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request:
         Update User Preferences (PUT http://sampleHost:8080/rest/userpreferences/update/1)
         */
        
        let urlString = String(format: "%@://%@/%@", targetProtocol.rawValue, URLRootString, URLActionString)
        
        guard let URL = URL(string: urlString) else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = REST_Methods.PATCH.rawValue
        
        // Headers
        
        if let headers = headers {
            for headerKey in headers.keys {
                let headerValue = headers[headerKey]!
                request.addValue(headerValue, forHTTPHeaderField: headerKey)
            }
        }
        
        // JSON Body
        
        if let bodyParams = bodyParams {
            
            let bodyObject: [String: Any] = bodyParams
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        }
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: completionBlock)   // as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
    }
}
