//
//  Coordinator.swift
//  Weather 5D
//
//  Created by Aldo Bergamini on 19/09/2018.
//  Copyright © 2018 iBat Inc. All rights reserved.
//

import UIKit


protocol Coordinator {
    
    var viewController: UIViewController { set get }
    
    func start()
}
