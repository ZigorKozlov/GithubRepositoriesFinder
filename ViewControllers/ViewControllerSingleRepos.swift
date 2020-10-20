//
//  ViewControllerSingleRepos.swift
//  gitRep
//
//  Created by Игорь Козлов on 17.10.2020.
//  Copyright © 2020 Игорь Козлов. All rights reserved.
//

import UIKit
import SafariServices

class ViewControllerSingleRepos: UIViewController {

    //MARK: - Data propertyes
    var dataVC1: RequestGithubData.Items?
    var userData: UserData?
    
    //MARK: - OutLets

    @IBOutlet weak var safariButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var topLable: UILabel!
    @IBOutlet weak var userNameLable: UILabel!
    @IBOutlet weak var emailLable: UILabel!
    @IBOutlet weak var repositoryLable: UILabel!
    @IBOutlet weak var nameRepositoryLable: UILabel!
    @IBOutlet weak var discriptionRepositoryLable: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData(with: dataVC1?.owner?.login)
        
        //MARK: -lable settings
        //avatarImageView
        avatarImageView.layer.cornerRadius = avatarImageView.layer.frame.size.height / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.borderWidth = 1
        
        //safariLable
        safariButton.layer.cornerRadius = safariButton.layer.frame.size.height / 2
        safariButton.clipsToBounds = true
        safariButton.layer.borderColor = UIColor.gray.cgColor
        safariButton.layer.borderWidth = 1
        
        //userNameLable
        userNameLable.layer.cornerRadius = userNameLable.frame.size.width / 50
        userNameLable.clipsToBounds = true
        userNameLable.layer.borderColor = UIColor.gray.cgColor
        userNameLable.layer.borderWidth = 0.5
        
        //emailLable
        emailLable.layer.cornerRadius = emailLable.frame.size.width / 50
        emailLable.clipsToBounds = true
        emailLable.layer.borderColor = UIColor.gray.cgColor
        emailLable.layer.borderWidth = 0.5
        
        repositoryLable.layer.cornerRadius = repositoryLable.frame.size.width / 50
        repositoryLable.clipsToBounds = true
        repositoryLable.layer.borderColor = UIColor.gray.cgColor
        repositoryLable.layer.borderWidth = 0.5
        
        nameRepositoryLable.layer.cornerRadius = nameRepositoryLable.frame.size.width / 50
        nameRepositoryLable.clipsToBounds = true
        nameRepositoryLable.layer.borderColor = UIColor.gray.cgColor
        nameRepositoryLable.layer.borderWidth = 0.5
        
        discriptionRepositoryLable.layer.cornerRadius = discriptionRepositoryLable.frame.size.width / 50
        discriptionRepositoryLable.clipsToBounds = true
        discriptionRepositoryLable.layer.borderColor = UIColor.gray.cgColor
        discriptionRepositoryLable.layer.borderWidth = 0.5
        
        topLable.layer.cornerRadius = topLable.frame.size.width / 10
        topLable.clipsToBounds = true
        

 
    }
    //MARK: - Load and update data
    func loadUserData(with name: String?) {

        guard let name = name else { return }

        guard let url = URL(string: "https://api.github.com/users/" + name ) else { return }
        print(url)
        URLSession.shared.dataTask(with: url) { [weak  self] (data, _, error) in //weak так как пользователь может закрыть VC
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                self?.userData = try decoder.decode(UserData.self, from: data)
                
                DispatchQueue.main.async {
                    self?.updateData()
                    self?.loadAvatar()
                }
                
            } catch {
                print(error)
            }
        }.resume()
        
        
    }
    
    func updateData() {
        if let login = dataVC1?.owner?.login {
            userNameLable.text = login
        } else {
            userNameLable.isHidden = true
        }
        if let email =  userData?.email {
            emailLable.text = email
        } else {
            emailLable.isHidden = true
        }
        if let name = dataVC1?.name {
            nameRepositoryLable.text = name
        } else {
            nameRepositoryLable.isHidden = true
        }
        if let description = dataVC1?.description {
            discriptionRepositoryLable.text = description
        } else {
            discriptionRepositoryLable.isHidden = true
        }
        
    }

    func loadAvatar() {
        DispatchQueue.main.async { [ weak self ]  in
            guard let path = self?.userData?.avatarURL else {
                self?.activityIndicator.isHidden = true
                return
            }
            guard let url = URL(string: path) else {
                self?.activityIndicator.isHidden = true
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                self?.activityIndicator.isHidden = true
                return
            }
            
            self?.avatarImageView.image = UIImage(data: data )
            self?.activityIndicator.isHidden = true
        }
    }
    
    
    //MARK:-Actions
    @IBAction func openInSafariWasPressed(_ sender: Any) {
        guard let path = dataVC1?.url else { return }
        guard let url = URL(string: path) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    @IBAction func saveWasPressed(_ sender: Any) {
        
    }
}
