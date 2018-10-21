//
//  SignUpController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase
import DLRadioButton

class SignUpController: UIViewController, UINavigationControllerDelegate {
    
    /// add profile image button
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    /// email text field
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    /// user name text field
    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    /// password text field
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    /// male radio button
    private lazy var maleRadioButton: DLRadioButton = {
        let maleButton = DLRadioButton()
        maleButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        maleButton.setTitle("Male", for: [])
        maleButton.setTitleColor(UIColor.lightGray, for: [])
        maleButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        maleButton.addTarget(self, action: #selector(handleMaleRadio), for: .touchUpInside)
        return maleButton
    }()
    
    /// female radio button
    private lazy var femaleRadioButton: DLRadioButton = {
        let femaleButton = DLRadioButton()
        femaleButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        femaleButton.setTitle("Female", for: [])
        femaleButton.setTitleColor(UIColor.lightGray, for: [])
        femaleButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        femaleButton.addTarget(self, action: #selector(handleFemaleRadio), for: .touchUpInside)
        return femaleButton
    }()
    
    /// sign up button
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    /// go to login button
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ",
                                                        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In",
                                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainBlue
            ]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    private var sex: String?
    
    private var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(handleTapOnView)))
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                        right: view.safeAreaLayoutGuide.rightAnchor,
                                        height: 50)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               paddingTop: 40,
                               width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusPhotoButton.layer.cornerRadius = 140 / 2
        
        setupInputFields()
        
        
    }
    
    /// set up the view of the input text field
    private func setupInputFields() {
        let label = UILabel()
        label.text = "Sex: "
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        let radioView = UIStackView(arrangedSubviews: [label, maleRadioButton, femaleRadioButton])
        radioView.distribution = .fillEqually
        radioView.axis = .horizontal
        radioView.spacing = 5
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField,
                                                       passwordTextField, radioView, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor,
                         paddingTop: 20, paddingLeft: 40, paddingRight: 40, height: 200)
    }
    
    /// reset the input text field
    private func resetInputFields() {
        emailTextField.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        emailTextField.isUserInteractionEnabled = true
        usernameTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
    }
    
    /// identify sign up is vaild
    private func isVaildSignUp(){
        // each field should be not empty
        let isFormValid = emailTextField.text?.isEmpty == false
            && usernameTextField.text?.isEmpty == false
            && passwordTextField.text?.isEmpty == false
            && (maleRadioButton.isSelected || femaleRadioButton.isSelected)
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.mainBlue
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc private func handleTapOnView(_ sender: UITextField) {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func handleTextInputChange() {
        isVaildSignUp()
    }
    
    @objc private func handleMaleRadio() {
        maleRadioButton.isSelected = true;
        femaleRadioButton.isSelected = false;
        self.sex = "male"
        
       isVaildSignUp()
    }
    
    @objc private func handleFemaleRadio() {
        maleRadioButton.isSelected = false;
        femaleRadioButton.isSelected = true;
        self.sex = "female"
        
        isVaildSignUp()
    }
    
    @objc private func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let sex = sex else { return }
        
        emailTextField.isUserInteractionEnabled = false
        usernameTextField.isUserInteractionEnabled = false
        passwordTextField.isUserInteractionEnabled = false
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        // use Auth to create a user in the Firebase
        Auth.auth().createUser(withEmail: email, username: username,
                               password: password, image: profileImage, sex: sex) { (err) in
            if err != nil {
                self.resetInputFields()
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController
                as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            mainTabBarController.selectedIndex = 0
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: UIImagePickerControllerDelegate

extension SignUpController: UIImagePickerControllerDelegate {
    /// the imgae picker
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        // set the imgae to the button
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImage = originalImage
        }
        plusPhotoButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        plusPhotoButton.layer.borderWidth = 0.5
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension SignUpController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any])
    -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

