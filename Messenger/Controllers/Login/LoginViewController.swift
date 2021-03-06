//
//  LoginViewController.swift
//  Messenger
//
//  Created by Alexandr Onischenko on 18.01.2022.
//
import Firebase
import UIKit
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Adress..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.setTitle("Log In", for: .normal)
        return button
    }()
    
    private let facebookLoginButton : FBLoginButton = {
        let loginButton = FBLoginButton()
        loginButton.permissions = ["public_profile", "email"]
        return loginButton
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(didTapLoginWithGoogle), for: .touchUpInside)
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let self = self else { return }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
        scrollView.addSubview(spinner)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 52)
        
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom + 10,
                                         width: scrollView.width - 60,
                                         height: 52)
    }
    
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // MARK: - Firebase sign in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            guard let result = result, error == nil else { return
                print("Failed to log in user with email")
            }
            let user = result.user
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged in user: \(user)")
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func didTapRegister() {
        let viewController = RegisterViewController()
        viewController.title = "Create Account"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

// MARK: - Facebook log in

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Log out button")
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: { connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            guard let firstName = result["first_name"] as? String,
                  let email = result["email"] as? String,
                  let lastName = result["last_name"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let url = data["url"] as? String else {
                      print("Failed to get email and name from fb result")
                      return
                  }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let user = ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                    DatabaseManager.shared.insertUser(with: user, completion: { success in
                        if success {
                            
                            guard let url = URL(string: url) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                                guard let data = data else {
                                    return
                                }
                                
                                let fileName = user.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let self = self else { return }
                
                guard authResult != nil, error == nil else {
                    print("Facebook credenrial login failed MFA may be needed")
                    return
                }
                
                print("Successfully logged user in")
                self.navigationController?.dismiss(animated: false, completion: nil)
            })
        })
    }
}

extension LoginViewController {
    @objc func didTapLoginWithGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print("Failed sign in with google. \(error)")
                return
            }
            
            print("Did sign in with google")
            
            
            guard let email = user?.profile?.email, let firstName = user?.profile?.givenName, let lastName = user?.profile?.familyName else {
                print("Failed getting email with google")
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            //uploadImage
                            
                            if ((user?.profile?.hasImage) != nil) {
                                guard let url = user?.profile?.imageURL(withDimension: 200) else { return }
                                
                                URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                                    guard let data = data else {
                                        return
                                    }
                                    
                                    let fileName = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                        switch result {
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                            print(downloadUrl)
                                        case .failure(let error):
                                            print("Storage manager error: \(error)")
                                        }
                                        
                                    })
                                }).resume()
                            }
                        }
                    })
                }
            })
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                print("Missing auth object off of google user")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let self = self else { return }
                guard authResult != nil, error == nil else {
                    print("Failed to log in with google credential")
                    return
                }
                
                print("Successfully signed in with google credential")
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
