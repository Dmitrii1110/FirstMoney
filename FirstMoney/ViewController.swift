//
//  ViewController.swift
//  FirstMoney
//
//  Created by admin1 on 30.01.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var numberFromKeyboard: [UIButton]!{
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

