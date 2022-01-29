//
//  NewConversationsViewController.swift
//  Messenger
//
//  Created by Alexandr Onischenko on 18.01.2022.
//

import UIKit
import JGProgressHUD

class NewConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    
    private let searchBar : UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for users..."
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "No results"
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}
