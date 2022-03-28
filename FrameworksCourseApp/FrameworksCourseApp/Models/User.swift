//
//  User.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 28.03.2022.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login: String = ""
    @objc dynamic var password: String = ""
    
    override static func primaryKey() -> String? {
        return "login"
    }
}
