//
//  ViewControllerSingleRepos.swift
//  gitRep
//
//  Created by Игорь Козлов on 17.10.2020.
//  Copyright © 2020 Игорь Козлов. All rights reserved.
//

import UIKit

class ViewControllerSingleRepos: UIViewController {

    //MARK: - Data propertyes
    var dataVC1: RequestGithubData.Items?
    var userData: UserData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData(with: dataVC1?.name)
    }
    
    //MARK: - Load and update data
    func loadUserData(with name: String?) {
        guard let name = name else { return }
        guard let url = URL(string: "https://api.github.com/users/" + name ) else { return }
        
        URLSession.shared.dataTask(with: url) { [unowned  self] (data, _, error) in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                self.userData = try decoder.decode(UserData.self, from: data)
               
                DispatchQueue.main.async {
                    self.updateData()
                }
                
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func updateData() {
        
    }

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
