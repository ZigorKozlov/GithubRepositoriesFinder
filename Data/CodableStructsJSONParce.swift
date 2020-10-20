//
//  CodableStructsJSONParce.swift
//  gitRep
//
//  Created by Игорь Козлов on 14.10.2020.
//  Copyright © 2020 Игорь Козлов. All rights reserved.
//
//
import UIKit
//MARK: declarate RequestGithubData struct
struct RequestGithubData: Codable {
    
    var items: [Items]?
    
    struct Items: Codable {
        enum CodingKeys: String, CodingKey{
            case name
            case description
            case url = "html_url"
            case owner
            case id
        }
        var id: Int?
        var name: String?
        var description: String?
        var url: String?
        var owner: Owner?
        //
        struct Owner: Codable {
            enum CodingKeys: String, CodingKey {
                case login
                case userEmail = "email"
                case avatarURL = "avatar_url"
            }
            var login: String?
            var avatarImage: UIImage?
            var userEmail: String?
            var avatarURL: String?
        }

    }
}

//struct UserData: Codable {
//    enum CodingKeys: String, CodingKey{
//        case avatarURL = "avatar_url"
//        case email
//    }
//
//    var avatarURL: String?
//    var email: String?
//    var avatar: UIImage?
//}
