//
//  DataService.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import Foundation


protocol DataService {
    
    func obtainEntityFor(key: String, withParameters passedData: [String: Any]?, andOnCompletion completionBlock: @escaping (_ result: Any?, _ error: Error?) -> Void)

}
