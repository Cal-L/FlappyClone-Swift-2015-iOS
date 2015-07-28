//
//  Goal.swift
//  test
//
//  Created by Cal on 4/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Goal: CCNode {
    
    func didLoadFromCCB() {
        self.physicsBody.sensor = true
    }
    
}
