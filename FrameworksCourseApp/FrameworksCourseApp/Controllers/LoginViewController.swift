//
//  LoginViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 28.03.2022.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var router: LaunchRouter?
    var realmUsers: Results<User>?
    var user = User()
    let realm = try! Realm()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        router = LaunchRouter(viewController: self)
        realmUsers = realm.objects(User.self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addingObservers()
    }
    
    deinit {
        removingObservers()
    }
    
    private func addingObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removingObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func loginButtonTapped() {
        guard let login = loginTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if login.isEmpty || password.isEmpty {
            let alert = UIAlertController(title: "Personal login and password required", message: "Please input the personal login and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)// Alert fill login
        } else {
            user.login = login
            user.password = password
            
            //Need check realm
            
            for realmUser in realmUsers! {
                print(realmUser)
            }
            router?.toMapViewController()
            
        }
    }
    
    private func registrationButtonTapped() {
        guard let login = loginTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if login.isEmpty || password.isEmpty {
            let alert = UIAlertController(title: "Personal login and password required", message: "Please input the personal login and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)// Alert fill login
        } else {
            user.login = login
            user.password = password
            
            //Need add realm checking
            realm.beginWrite()
            try! realm.write {
                realm.add(user)
            }
            realm.cancelWrite()
            router?.toMapViewController()
        }
    }
    
    
    @objc private func keyboardShown(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.height)
    }
    @objc private func keyboardHidden() {
        scrollView.contentOffset = CGPoint.zero
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func screenTapped() {
        keyboardHidden()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        keyboardHidden()
        loginButtonTapped()
    }
    @IBAction func registrationButtonTapped(_ sender: UIButton) {
        keyboardHidden()
        registrationButtonTapped()
    }
    
    
}
