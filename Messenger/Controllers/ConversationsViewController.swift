//
//  ViewController.swift
//  Messenger
//
//  Created by Alexandr Onischenko on 18.01.2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet var tableView: UITableView!
    
//    private let tableView: UITableView = {
//        let table = UITableView()
//        table.backgroundColor = .red
//        table.isHidden = true
//        return table
//    }()
    
    @IBOutlet var noConversationsLabel: UILabel!
    
//    private let noConversationsLabel: UILabel = {
//        let label = UILabel()
//        label.text = "No conversations!"
//        label.textAlignment = .center
//        label.textColor = .gray
//        label.font = .systemFont(ofSize: 21, weight: .medium)
//        label.isHidden = true
//        return label
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        setupTableView()
        fetchConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let viewController = LoginViewController()
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .fullScreen
            view.window?.overrideUserInterfaceStyle = .light
            	
            present(nav, animated: false, completion: nil)
        }
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        
        noConversationsLabel.text = "No conversations!"
        noConversationsLabel.textAlignment = .center
        noConversationsLabel.textColor = .gray
        noConversationsLabel.font = .systemFont(ofSize: 21, weight: .medium)
        noConversationsLabel.isHidden = true
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
        noConversationsLabel.isHidden = true
    }
    
    @objc func didTapComposeButton() {
        let viewController = NewConversationsViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello world"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewController = ChatViewController()
        viewController.title = "Jenny Smith"
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }
}
