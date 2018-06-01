//
//  TimerSectionsVC.swift
//  GymTime
//
//  Created by maf macbook on 23/05/2017.
//  Copyright © 2017 maf macbook. All rights reserved.
//

import UIKit
import CoreData
class TimerSectionsVC: UITableViewController {
    
    
    var timersSectionsArray = [TimerSections]()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertView = UIAlertController(title: "Add New Timer", message: "Add Timer", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (alert) in
            let newTimer = TimerSections(context: self.managedContext)
            newTimer.name = textField.text!
            self.timersSectionsArray.append(newTimer)
            self.tableView.reloadData()
            self.saveContext()
        }

        action.isEnabled = false; //to make it disable while presenting
        alertView.addTextField { (alertTextField) in
            textField.placeholder = "Add a new timer section"
            textField = alertTextField
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        }
        alertView.addAction(action)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alertView, animated: true, completion: nil)
    }
    @objc func alertTextFieldDidChange(field: UITextField){
        let alertController:UIAlertController = self.presentedViewController as! UIAlertController;
        let textField :UITextField  = alertController.textFields![0];
        let addAction: UIAlertAction = alertController.actions[0];
        addAction.isEnabled = (textField.text?.characters.count)! >= 1;
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContext()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return timersSectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifiers.timers, for: indexPath)
        cell.textLabel?.text = timersSectionsArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     performSegue(withIdentifier: "GotoTimers", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TimersVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = timersSectionsArray[indexPath.row]
        }
        
    }
    
    func saveContext() {
        
        do {
            try managedContext.save()
        } catch  {
            print(error)
        }
    }
    
    func loadContext(with request: NSFetchRequest<TimerSections> = TimerSections.fetchRequest()) {

        do {
            timersSectionsArray =  try managedContext.fetch(request)
        } catch {
            print("error fecthing data")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table View
    
    

}
