//
//  GithubUsersVC.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

extension GithubUsersVC: P_KeyboardObservable {
    
    var keyboardObserveOptions: KeyboardObservableOptions { .showHide }
    
}

final class GithubUsersVC: UITableViewController {
    
    // MARK: - UI elements
    
    // MARK: - Private properties
    private let githubUsersService: P_GithubUsersService
    private var users = [GithubUserNO]()
    
    // MARK: - Init
    required init(
        githubUsersService: P_GithubUsersService
    ) {
        self.githubUsersService = githubUsersService
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchUsers()
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = user.login
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let vc = GithubUserVC(
            user: user,
            githubRepositoriesService: GithubRepositoriesService(networkClient: NetworkClient())
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let searchBar = UISearchBar()
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 56).isActive = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        return view
    }
    
}

// MARK: - Setup UI
private extension GithubUsersVC {
        
    func setupUI() {
        tableView.keyboardDismissMode = .onDrag
    }
    
}

private extension GithubUsersVC {
    
    func fetchUsers() {
        githubUsersService.get { [weak self] (result) in
            switch result {
            case .success(let models):
                self?.users = models
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func searchUsers(query: String) {
        githubUsersService.search(query: query) { [weak self] (result) in
            switch result {
            case .success(let model):
                self?.users = model.items
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension GithubUsersVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        if trimmedSearchText.isEmpty {
            fetchUsers()
        } else {
            searchUsers(query: trimmedSearchText)
        }
    }
    
}
