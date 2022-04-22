//
//  PhotoMarker.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 22.04.2022.
//

import Foundation
import RealmSwift

class PhotoMarker: Object {
    @objc dynamic var photo = UIImage(named: "unknownFace")
}
