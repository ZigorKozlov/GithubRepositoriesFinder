//
//  CodableStructsJSONParce.swift
//  gitRep
//
//  Created by Игорь Козлов on 14.10.2020.
//  Copyright © 2020 Игорь Козлов. All rights reserved.
//
//
import Foundation

//MARK: declarate RequestGithubData struct
struct RequestGithubData: Codable {
    
    var items: [Items]?
    
    struct Items: Codable {
        enum CodingKeys: String, CodingKey{
            case name
            case description
            case url
            case owner
        }
        var name: String?
        var description: String?
        var url: String?
        var owner: Owner?
        
        struct Owner: Codable {
            var login: String?
            var avatarURL: String?
            var url: String?

            enum CodingKeys: String, CodingKey{
                case login
                case avatarURL = "avatar_url"
                case url
            }
        }

    }
}
//Полное имя репозитория, его описание, полное имя владельца репозитория, майл владельца
//https://developer.github.com/v3/users/#get-a-single-user
//https://developer.github.com/v3/search/#search-repositories
"login": "dtrupenn",
       "id": 872147,
