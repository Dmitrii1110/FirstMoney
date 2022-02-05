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

    @IBOutlet weak var displayLabel: UILabel!
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
        tableView.reloadData() //обновление экрана после нажатия на кнопки
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray[indexPath.row]
        
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
        
        let editingRow = spendingArray[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {  (contextualAction, view, boolValue) in
            
            try! self.realm.write {
                self.spendingArray.realm?.delete(editingRow)
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


