//
//  ViewController.swift
//  FirstMoney
//
//  Created by admin1 on 30.01.2022.
//

import UIKit
import RealmSwift
import CoreData

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var spendingArray: Results<Spending>!

    
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howManyCanSpend: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var allSpending: UILabel!
    
    
    var stillTyping = false //Чтобы убирать 0 в начале строки
    @IBOutlet var numberFromKeyboard: [UIButton]!{
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    var categoryName = ""
    var displayValue: Int = 1
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingArray = realm.objects(Spending.self)
        leftLabels() //отображаем текущий лимит из БД
        spendingAllTime()
        
    }

    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        if number == "0" && displayLabel.text == "0" {
            stillTyping = false
        } else {
            
            if stillTyping {
                if displayLabel.text!.count < 15 {
                    displayLabel.text = displayLabel.text! + number
                    
                }
            } else {
                displayLabel.text = number
                stillTyping = true
            }
            
            
            
        }
    }

    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
        }
        leftLabels()
        spendingAllTime()
        tableView.reloadData() //обновление экрана после нажатия на кнопки
        
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { action in
                                                                                 
            let tfsum = alertController.textFields?[0].text
    
            
            let tfday = alertController.textFields?[1].text
            
            guard tfday != "" && tfsum != "" else { return }
            
            self.limitLabel.text = tfsum
            
            if let day = tfday {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                //запись в БД
                let limit = self.realm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                } else {
                    try! self.realm.write {
                        limit[0].limitSum = self.self.limitLabel.text!
                        limit[0].limitDate = dateNow as NSDate
                        limit[0].limitLastDay = lastDay as NSDate
                    }
                }
                
                
            }
            
            self.leftLabels()
            
            
        }
        
        alertController.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
            
        }
        
        alertController.addTextField { (day) in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { _ in }
        
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //отображаем текущий лимит из БД
    func leftLabels() {
        let limit = self.realm.objects(Limit.self)
        
        guard limit.isEmpty == false else {return}
        
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date

        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)

        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00") as Any
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any

        let filtredLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")

        spendByCheck.text = "\(filtredLimit)" //перезапись и сохр нового лимита
        
        let a = Int(limitLabel.text!)!
        let b = Int(spendByCheck.text!)!
        let c = a - b
        
        //все расходы
        howManyCanSpend.text = "\(c)"
        
        //расходы за месяц:
        let dateNow = Date()
        let dateComponentsNow = calendar.dateComponents([.year, .month, .day], from: dateNow)
        
        let lastDayMonth : Int
        
        if Int(dateComponentsNow.year!) % 4 == 0 && dateComponentsNow.month == 2 {
            lastDayMonth = 29
        } else {
            switch dateComponentsNow.month {
            case  1: lastDayMonth = 31
            case  2: lastDayMonth = 28
            case  3: lastDayMonth = 31
            case  4: lastDayMonth = 30
            case  5: lastDayMonth = 31
            case  6: lastDayMonth = 30
            case  7: lastDayMonth = 31
            case  8: lastDayMonth = 31
            case  9: lastDayMonth = 30
            case  10: lastDayMonth = 31
            case  11: lastDayMonth = 30
            case  12: lastDayMonth = 31
                
            default: return
        }
        }
        
        let startDateMonth = formatter.date(from: "\(dateComponentsNow.year!)/\(dateComponentsNow.month!)/01 00:00") as Any
        let endDateMonth = formatter.date(from: "\(dateComponentsNow.year!)/\(dateComponentsNow.month!)/\(lastDayMonth) 23:59") as Any
        
        let filtredMonth: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDateMonth, endDateMonth).sum(ofProperty: "cost")
        
        print(filtredMonth)

    }
    
    func spendingAllTime() {
        
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        
        cell.recordCategory.text = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
        case "Еда": cell.recordImage.image = #imageLiteral(resourceName: "eda")
        case "Одежда": cell.recordImage.image = #imageLiteral(resourceName: "odejda")
        case "Связь": cell.recordImage.image = #imageLiteral(resourceName: "svyz")
        case "Досуг": cell.recordImage.image = #imageLiteral(resourceName: "dosug")
        case "Красота": cell.recordImage.image = #imageLiteral(resourceName: "krasota")
        case "Авто": cell.recordImage.image = #imageLiteral(resourceName: "avto")
        default: cell.recordImage.image = #imageLiteral(resourceName: "Ultramarine.png")
        }
        
        return cell
    }
    
    //ниже функция для удаления записей в tableView
    //Нужно найти решение как работает новый метод!!!!
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editingRow = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {  (contextualAction, view, boolValue) in
            
            try! self.realm.write {
                self.spendingArray.realm?.delete(editingRow)
                self.leftLabels()
                self.spendingAllTime()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
}


