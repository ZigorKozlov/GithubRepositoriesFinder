//
//  TableViewControllerSaved.swift
//  gitRep
//
//  Created by Игорь Козлов on 17.10.2020.
//  Copyright © 2020 Игорь Козлов. All rights reserved.
//

import UIKit

class TableViewControllerSaved: UITableViewController {

    //Main Data
    var savedData: RequestGithubData?
    //CallBacks
    var callBackToVC1: ( (RequestGithubData?)-> () )?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Регистрация ячейки
        tableView.register(UINib(nibName: "MyTableViewMainCell", bundle: nil), forCellReuseIdentifier: "tVMainCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return savedData?.items?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tVMainCell", for: indexPath) as! MyTableViewMainCell//Для переиспользования ячеек( эффективное использование памяти)

        // Configure the cell...
        
        cell.topLable.text = savedData?.items?[indexPath.row].name
        cell.BottomLable.text = savedData?.items?[indexPath.row].description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goTosavedSingleVC", sender: self)
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            savedData?.items?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let temp = savedData?.items?[fromIndexPath.row]
        savedData?.items?.remove(at: fromIndexPath.row)
        savedData?.items?.insert(temp!, at: to.row)
        tableView.reloadData()
    }
    

    //MARK:- Actions
    @IBAction func editPressed(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if case let controller as ViewControllerSingleRepos = segue.destination, segue.identifier == "goTosavedSingleVC" {
            guard let index = tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: index, animated: true)
            controller.dataVC1 = savedData?.items?[index.row]
        }
    }
    
    deinit {
        callBackToVC1?(savedData)
    }
}
