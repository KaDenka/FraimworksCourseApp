//
//  SelfieViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 20.04.2022.
//

import UIKit

class SelfieViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        // Do any additional setup after loading the view.
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
