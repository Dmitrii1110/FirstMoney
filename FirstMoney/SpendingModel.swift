//
//  SpendingModel.swift
//  FirstMoney
//
//  Created by admin1 on 04.02.2022.
//

import RealmSwift

class Spending: Object {
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
    
}
