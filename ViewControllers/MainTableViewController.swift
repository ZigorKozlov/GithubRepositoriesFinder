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
    private var savedData: RequestGithubData? {
        set {
            if let newValue = newValue {
                let jsonEncoder = JSONEncoder()
                let encodedData = try? jsonEncoder.encode(newValue)
            
                UserDefaults.standard.setValue( encodedData, forKey: "GitRepIgorKozlov")
                UserDefaults.standard.synchronize()
            }
        }
        get {
            
            let jsonDecoder = JSONDecoder()
            
            if let data = UserDefaults.standard.data(forKey: "GitRepIgorKozlov") {
                if let decodeData = try? jsonDecoder.decode(RequestGithubData.self, from: data) {
                    
                    return decodeData
                } else { return RequestGithubData() }
            } else { return RequestGithubData() }
        }
    }
    
    //MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Регистрация ячейки
        tableView.register(UINib(nibName: "MyTableViewMainCell", bundle: nil), forCellReuseIdentifier: "tVMainCell")
        
        //searchController Delegate settings
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
        
        cell.topLable.text = respData?.items?[indexPath.row].name
        cell.BottomLable.text = respData?.items?[indexPath.row].description
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSingleRepose", sender: self)//Инициируем переход
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //MARK: toViewControllerSingleRepos
        if case let controller as ViewControllerSingleRepos = segue.destination, segue.identifier == "goToSingleRepose" {
            guard let index = tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: index, animated: true)
            controller.dataVC1 = respData?.items?[index.row]
            
            
            //CallBack
            controller.callBackToVC1 = {
                [ unowned self ]
                ( data ) in
                
                //Если есть элемент с таким id то меняем его, иначе добавляем новый в сохранённые
                for (index, elem) in (self.savedData?.items ?? []).enumerated() {
                    if elem.id != nil, data?.id != nil, elem.id! == data!.id! {
                        guard let data = data else { return }
                        self.savedData?.items?[index] = data

                        return
                    }
                }
                //
                guard let data = data else { return }
                self.savedData?.items?.append(data)
                
            }
            //
            
        }
        
        //MARK: - ToViewControllerSaved
        if case let controller as TableViewControllerSaved = segue.destination, segue.identifier == "goToSavedDataTVC" {
            controller.savedData = savedData
            
            controller.callBackToVC1 =  {
                [unowned self]
                (data) in
                savedData = data
            }
        }
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

