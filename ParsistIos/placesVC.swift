//
//  placesVC.swift
//  ParsistIos
//
//  Created by Erdo on 21.01.2019.
//  Copyright © 2019 Erdo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
class placesVC: UIViewController , UITableViewDelegate , UITableViewDataSource {
    var placeNameArray = [String]() //çekilen isimleri buna kaydedip tableviewda gösterilecek
    var chosenPlace = "" //detailVC ye tableviewdan secilen değeri bunla aktarcam
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirebase()
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromplacesVCtodetailsVC" {
            let destinationVC = segue.destination as! detailsVC
                destinationVC.selectedPlace = self.chosenPlace //tableviewdaki ismi detailVC ye aktardık
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenPlace = placeNameArray[indexPath.row]
        self.performSegue(withIdentifier: "fromplacesVCtodetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNameArray[indexPath.row].capitalized
        return cell
    }
    
    func getDataFromFirebase(){
        self.placeNameArray.removeAll(keepingCapacity: false) //array güvenliği her çalıştırıldığında sıfırlanacak.
        let databaseReference = Database.database().reference()
        databaseReference.child("Locations").observe(DataEventType.childAdded, with: { (snapshot) in
            let values = snapshot.value as! NSDictionary
            let locationID = values.allKeys //all keys taken
         
            for id in locationID{
                let singleLocation = values[id] as! NSDictionary
                self.placeNameArray.append(singleLocation["parkname"] as! String)
                
            }
            self.tableView.reloadData()
           
            
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
            let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
  
  }
    
}
