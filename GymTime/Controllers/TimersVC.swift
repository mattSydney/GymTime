//
//  TimersVC.swift
//  GymTime
//
//  Created by maf macbook on 21/05/2017.
//  Copyright © 2017 maf macbook. All rights reserved.
//

import UIKit
import CoreData

class TimersVC: UITableViewController {
    
    var timersArray = [Timer]()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: TimerSections? {
        didSet{
            loadContext()
        }
    }
    // MARK: IBACTIONS
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alertView = UIAlertController(title: "Add New Timer", message: "Add Timer", preferredStyle: .alert)
       
        let action = UIAlertAction(title: "Add", style: .default) { (alert) in
            let newTimer = Timer(context: self.managedContext)
            newTimer.title = textField.text!
            newTimer.done = false
            newTimer.parent = self.selectedCategory
            self.timersArray.append(newTimer)
            self.tableView.reloadData()
            self.saveContext()
        }
        action.isEnabled = false; //to make it disable while presenting
        alertView.addTextField { (alertTextField) in
            textField.placeholder = "Add a new timer"
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
        addAction.isEnabled = (textField.text?.characters.count)! >= 5;
        
    }
    
    func addTimer() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContext()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return timersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewIdentifiers.timers, for: indexPath)
        cell.textLabel?.text = timersArray[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        timersArray[indexPath.row].done = !timersArray[indexPath.row].done
        
        tableView.cellForRow(at: indexPath)?.accessoryType = timersArray[indexPath.row].done ? .checkmark : .none
        saveContext()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveContext() {
        
        do {
            try managedContext.save()
        } catch  {
            print(error)
        }
    }
    
    func loadContext(with request: NSFetchRequest<Timer> = Timer.fetchRequest(), predicate: NSPredicate? = nil) {
        let predicateTimers = NSPredicate(format: "parent.name MATCHES %@", selectedCategory!.name!)
        
        if let addPredicate = predicate {
         request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTimers, addPredicate])
        } else {
         request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTimers])
        }
        
        do {
            timersArray =  try managedContext.fetch(request)
        } catch {
            print("error fecthing data")
        }
        tableView.reloadData()
    }
}

extension TimersVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Timer> = Timer.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadContext(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadContext()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}


