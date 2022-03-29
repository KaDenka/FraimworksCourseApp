//
//  LoginViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 28.03.2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
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
        
    }
    @IBAction func registrationButtonTapped(_ sender: UIButton) {
        keyboardHidden()
    }
    

}
