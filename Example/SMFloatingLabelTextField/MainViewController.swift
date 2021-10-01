//
//  MainViewController.swift
//  SMFloatingLabelTextField_Example
//
//  Created by Miroslaw Stanek on 01/10/2021.
//  Copyright © 2021 Michał Moskała. All rights reserved.
//

import Foundation
import UIKit
import SMFloatingLabelTextField

class MainViewController: UIViewController {
    
    @IBOutlet weak var lastName: FloatingLabelTextField!
    @IBOutlet weak var firstName: FloatingLabelTextField!
    @IBOutlet weak var address: FloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lastName.attributedPlaceholder = NSAttributedString.init(string: "Last name text",
                                                                      attributes: [
                                                                        NSAttributedString.Key.foregroundColor: UIColor.magenta,
                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.bold),
                                                                        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single
                                                                    ])
        self.address.text = "Main Square, Kraków, Poland"
    }
}
