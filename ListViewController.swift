//
//  ListViewController.swift
//  MapsApp
//
//  Created by Berkay Kargılı on 3.03.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameData = [String]()
    var idData = [UUID]()
    var chosenPlaceName = ""
    var chosenPlaceID : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
     
        takeData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(takeData), name: NSNotification.Name("newPlaceCompleted"), object: nil)
    }
        
    @objc func takeData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        request.returnsObjectsAsFaults = false
        
        do {
        
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                nameData.removeAll(keepingCapacity: false)
                idData.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameData.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idData.append(id)
                    }
                }
                
                tableView.reloadData()
            }
            
        } catch {
            print("MISTAKE")
        }
    }
    
    
    @objc func plusButtonTapped() {
        chosenPlaceName = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
                                                                                          

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenPlaceName = nameData[indexPath.row]
        chosenPlaceID = idData[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapViewControllers
            destinationVC.chosenName = chosenPlaceName
            destinationVC.chosenID = chosenPlaceID
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
            let uuidString = idData[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idData[indexPath.row] {
                                context.delete(result)
                                nameData.remove(at: indexPath.row)
                                idData.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    
                                }
                               
                                break
                            }
                        }
                    }
                }
            
            } catch {
                print("MISTAKE")
            }
        }
    }

}
