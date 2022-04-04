//
//  LoginViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 28.03.2022.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    //MARK: -- Outlets
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: -- Properties
    
    var router: LaunchRouter?
    var realmUsers: Results<User>?
    var user = User()
    let realm = try! Realm()
    
    //MARK: Overrided funcs
    
    override func viewWillAppear(_ animated: Bool) {
        
        router = LaunchRouter(viewController: self)
        realmUsers = realm.objects(User.self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        
        
        configAndSecureTextFields(loginTextField, passwordTextField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addingObservers()
    }
    
    //MARK: -- Init & Deinit
    
    deinit {
        removingObservers()
    }
    
    //MARK: -- Private funcs
    
    private func addingObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(blurViewLoading), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(normalViewLoading), name: UIApplication.didBecomeActiveNotification, object: nil)
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
            if (realm.object(ofType: User.self, forPrimaryKey: "\(login)") != nil) {
                router?.toMapViewController()
            } else {
                let alert = UIAlertController(title: "No such registered user", message: "Please make the registration", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
            }
            
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
            if realm.object(ofType: User.self, forPrimaryKey: "\(login)") != nil {
                let alert = UIAlertController(title: "Such user had been registered", message: "Please push the login button", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
            } else {
                try! realm.write {
                    realm.add(user)
                }
                router?.toMapViewController()
            }
        }
    }
    
    private func configAndSecureTextFields(_ loginTextField: UITextField, _ passwordTextField: UITextField) {
        loginTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
        loginTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        loginTextField.keyboardType = UIKeyboardType.emailAddress
        passwordTextField.keyboardType = UIKeyboardType.default
        loginTextField.returnKeyType = .default
        passwordTextField.returnKeyType = .default
    }
    
    //MARK: -- @objc funcs
    
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
    
    @objc private func blurViewLoading() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        blurEffectView.tag = 1

        self.view.addSubview(blurEffectView)
    }
    
    @objc private func normalViewLoading() {
        self.view.viewWithTag(1)?.removeFromSuperview()
    }
    
    //MARK: -- Actions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        keyboardHidden()
        loginButtonTapped()
    }
    @IBAction func registrationButtonTapped(_ sender: UIButton) {
        keyboardHidden()
        registrationButtonTapped()
    }
    
    
}
