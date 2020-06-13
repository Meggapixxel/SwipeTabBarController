//
//  GithubUserVC.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit
import Kingfisher

final class GithubUserVC: UIViewController {
    
    // MARK: - UI elements
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties
    private let user: GithubUserNO
    private let githubRepositoriesService: P_GithubRepositoriesService
    private var repositories = [GithubRepositoryNO]()
    
    // MARK: - Init
    init(
        user: GithubUserNO,
        githubRepositoriesService: P_GithubRepositoriesService
    ) {
        self.user = user
        self.githubRepositoriesService = githubRepositoriesService
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
        getRepositories()
    }
    
}

// MARK: - Setup UI
private extension GithubUserVC {
    
    func setupUI() {
        imageView.kf.setImage(with: URL(string: user.avatarUrl))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

private extension GithubUserVC {
    
    func getRepositories() {
        githubRepositoriesService.get(user: user.login) { [weak self] (result) in
            switch result {
            case .success(let models):
                self?.repositories = models
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension GithubUserVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = repositories[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = String(repository.id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let _ = CoreDataClient { [weak self] result in
            switch result {
            case .success(let client):
                let vc = GithubCommitsVC(
                    repository: repository,
                    databaseCommitService: DatabaseCommitService<DatabaseAuthorService>(client: client),
                    networkCommitService: GithubCommitsService(networkClient: NetworkClient())
                )
                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}
