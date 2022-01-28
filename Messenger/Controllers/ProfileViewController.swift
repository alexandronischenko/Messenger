//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Alexandr Onischenko on 18.01.2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {

    let data = ["Log out"]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "", message: "Do you want to log out?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            FBSDKLoginKit.LoginManager().logOut()
            
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let viewController = LoginViewController()
                let nav = UINavigationController(rootViewController: viewController)
                nav.modalPresentationStyle = .fullScreen
                    
                self.present(nav, animated: false, completion: nil)
                
            } catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
}
