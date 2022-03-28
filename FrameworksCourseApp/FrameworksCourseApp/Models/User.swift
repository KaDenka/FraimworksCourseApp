//
//  User.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 28.03.2022.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic let login: String
    @objc dynamic var password: String
    
    init(login: String, password: String) {
        self.login = login
        self.password = password
    }
    
    func primaryKey() {
        
    }
}
