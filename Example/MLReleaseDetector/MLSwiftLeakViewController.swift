//
//  MLSwiftLeakViewController.swift
//  MLReleaseDetector_Example
//
//  Created by mazhipeng on 2022/4/17.
//  Copyright © 2022 mazhipeng. All rights reserved.
//

import UIKit

typealias MLBlock = ()->Void

@objcMembers class MLSwiftPerson : NSObject {
    var block: MLBlock?
}

@objcMembers class MLSwiftLeakViewController: UIViewController {
    var person: MLSwiftPerson?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.title = "Swift Leak"
        
        self.person = MLSwiftPerson()
        self.person?.block = {
            print(self.person)
        }
    }
}
