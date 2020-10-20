//
//  MainTableViewController.swift
//  gitRep
//
//  Created by Игорь Козлов on 12.10.2020.
//  Copyright © 2020 Игорь Козлов. All rights reserved.
//

import UIKit


//MARK: - MainTableViewController
class MainTableViewController: UITableViewController {

    var task: URLSessionDataTask?
    
    //UISearchController
    private var searchController = UISearchController(searchResultsController: nil)
    
    //responceData
    private var respData: RequestGithubData?
    private var savedData: RequestGithubData? = RequestGithubData()
    
    //MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Регистрация ячейки
        tableView.register(UINib(nibName: "MyTableViewMainCell", bundle: nil), forCellReuseIdentifier: "tVMainCell")
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.isSearchResultsButtonSelected = true
        
        
        //setup the searchController
        searchController.searchResultsUpdater = self //Получатель информации об изменинии в строке поиска данный класс
        searchController.obscuresBackgroundDuringPresentation = false // Что бы не затемнялся отображаемый при поиске контент
        searchController.searchBar.placeholder = "Enter the Gir Repository name"
        
        navigationItem.searchController = searchController //Интеграция searchController в navigationBar
        definesPresentationContext = true // Опускает строку поиска при переходе на другой экран
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        respData?.items?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tVMainCell", for: indexPath) as! MyTableViewMainCell//Для переиспользования ячеек( эффективное использование памяти)

        // Configure the cell...
        
       // cell.textLabel?.text = respData?.items?[indexPath.row].name
        cell.topLable.text = respData?.items?[indexPath.row].name
        cell.BottomLable.text = respData?.items?[indexPath.row].description
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSingleRepose", sender: self)//Инициируем переход
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if case let controller as ViewControllerSingleRepos = segue.destination, segue.identifier == "goToSingleRepose" {
            guard let index = tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: index, animated: true)
            controller.dataVC1 = respData?.items?[index.row]
            
            controller.callBackToVC1 = {
                [ unowned self ]
                ( data ) in
                
                //Если есть элемент с таким id то меняем его, иначе добавляем новый в сохранённые
                for (index, elem) in (self.savedData?.items ?? []).enumerated() {
                    if elem.id != nil, data?.id != nil, elem.id! == data!.id! {
                        guard let data = data else { return }
                        self.savedData?.items?[index] = data
                        break
                    }
                }
                //
                guard let data = data else { return }
                self.savedData?.items?.append(data)
                
            }
            
        }
        
        if case let controller as TableViewControllerSaved = segue.destination, segue.identifier == "goToSavedDataTVC" {
            controller.savedData = savedData
            
        }
                //Аналогично верхнему условию
        //        if segue.identifier == "goToSingleRepose" {
        //            let controller = segue.destination as! ViewControllerSingleRepos
        //        }
            
    }

    //MARK:- Actions
    @IBAction func refreshControlAction(_ sender: Any) {
        refreshControl?.endRefreshing()
        updateSearchResults(for: searchController)
        
    }
}

//MARK: - Extension MainTableViewController: UISearchResultsUpdating
extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText != "" else { return }
        
        let foundStr = "https://api.github.com/search/repositories?q=" + searchText.lowercased()
        foundGithubRep(to: foundStr)
    }
    
    func foundGithubRep(to path: String) {
        
        guard let url = URL(string: path)
            else { return }
        
        if let task = task {
            if task.state == .running {
                task.cancel()
            }
        }
            
        task = URLSession.shared.dataTask(with: url) { [unowned self](data, _, error) in
           
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                self.respData = try decoder.decode(RequestGithubData.self, from: data)
               
            } catch {
            }
            
            // Отправляем вызов данного блока кода в основной поток
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        task?.resume()
        
    }
}

