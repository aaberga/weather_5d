//
//  LoggingMethods.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 18/05/2017.
//  Copyright © 2017 iBat Inc. All rights reserved.
//

import Foundation

private func splitName(file: String, forLevels levels: Int = 1) -> String {
    
    var className = ""
    if levels == 1 {
        className = (file as NSString).lastPathComponent
    } else {
        let filePathComponents = (file as NSString).components(separatedBy: "/")
        let length = filePathComponents.count
        let start = length - levels
        let end = length-1
        
        let levelComponents = filePathComponents[start...end]
        className = levelComponents.joined(separator: "/")
    }

    return className
}


public func DLogWith(message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, classPathLevels: Int = 1) {
    
    #if DEBUG
        let className = splitName(file: file, forLevels: classPathLevels)
        print("DLog: \(className) : \(function) : [#\(line):\(column)]  - \(message)")
    #endif
}



public func DLogWith(object: Any, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, classPathLevels: Int = 1) {
    
    #if DEBUG
        let className = splitName(file: file, forLevels: classPathLevels)
        print("DLog: \(className) : \(function) : [#\(line):\(column)] | \(object)")
    #endif
}
