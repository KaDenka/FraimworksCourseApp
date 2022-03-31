//
//  LaunchRouter.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 29.03.2022.
//

import Foundation
import UIKit

class LaunchRouter: Router {
    init(viewController: UIViewController) {
        super.init(controller: viewController)
    }
    
    func toMapViewController() {
        perform(segue: "toMapViewController")
    }
}
