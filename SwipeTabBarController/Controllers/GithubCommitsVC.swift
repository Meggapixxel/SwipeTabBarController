//
//  GithubCommitsVC.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 26.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

final class GithubCommitsVC: UITableViewController {

    private let fetchApiCommitsRefreshControl = UIRefreshControl()
    
    private lazy var coreDataClient = CoreDataClient()
    private lazy var authorDatabaseService: P_DatabaseAuthorService = DatabaseAuthorService(
        client: coreDataClient
    )
    private lazy var commitsDatabaseService: P_DatabaseCommitService = DatabaseCommitService<DatabaseAuthorService>(
        client: coreDataClient
    )
    private lazy var apiClient = ApiClient()
    
    private var commits = [CommitMO]()
    private var databasePredicate: DatabasePredicate<CommitMO>? {
        didSet { loadSavedData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        performSelector(inBackground: #selector(fetchApiCommits), with: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Commit")

        let commit = commits[indexPath.row]
        cell.textLabel?.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "GithubCommitVC") as? GithubCommitVC else { return }
        vc.commit = commits[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let commit = commits[indexPath.row]
        do {
            try commitsDatabaseService.delete(model: commit)
        } catch {
            return print(error)
        }
        commits.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
}

// MARK: - Setup UI
private extension GithubCommitsVC {
    
    func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(changeFilter)
        )
        
        fetchApiCommitsRefreshControl.addTarget(self, action: #selector(fetchApiCommits), for: .valueChanged)
        tableView.refreshControl = fetchApiCommitsRefreshControl
    }
    
}

// MARK: - Actions
private extension GithubCommitsVC {
    
    @objc func loadSavedData() {
        commitsDatabaseService.get(sort: .desc(\.date), predicate: databasePredicate) { [weak self] (result) in
            self?.fetchApiCommitsRefreshControl.endRefreshing()
            switch result {
            case .success(let commits):
                self?.commits = commits
            case .failure(let error):
                self?.commits = []
                print(error)
            }
            self?.tableView.reloadData()
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits…", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [weak self] _ in
            self?.databasePredicate = DatabasePredicate<CommitMO>.not(.beginsWith(keyPath: \.message, value: "Merge pull request", option: .caseSensitive))
        })
        ac.addAction(UIAlertAction(title: "Fixes", style: .default) { [weak self] _ in
            self?.databasePredicate = .contains(keyPath: \.message, value: "fix", option: .caseInsensitive)
        })
        ac.addAction(UIAlertAction(title: "Recent", style: .default) { [weak self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self?.databasePredicate = .greater(keyPath: \.date, value: twelveHoursAgo)
        })
        ac.addAction(UIAlertAction(title: "Recent fixes", style: .default) { [weak self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self?.databasePredicate = DatabasePredicate<CommitMO>.greater(keyPath: \.date, value: twelveHoursAgo)
                .and(.contains(keyPath: \.message, value: "fix", option: .caseInsensitive))
        })
        ac.addAction(UIAlertAction(title: "Durian commits", style: .default) { [weak self] _ in
            print(NSPredicate(format: "author.name == 'Joe Groff'"))
            self?.databasePredicate = .equals(keyPath: \.author.name, value: "Joe Groff")
        })
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [weak self] _ in
            self?.databasePredicate = nil
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func fetchApiCommits() {
        commitsDatabaseService.latest { result in
            switch result {
            case .success(let newestCommit):
                self.apiClient.fetchCommits(sinceDate: newestCommit?.date) { (result) in
                    switch result {
                    case .success(let apiCommits):
                        print("Received \(apiCommits.count) new commits.")
                        self.commitsDatabaseService.save(apiModels: apiCommits) { (result) in
                            DispatchQueue.main.async { [unowned self] in
                                switch result {
                                case .success(_):
                                    self.loadSavedData()
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
extension Date: CVarArg { }

class GithubCommitVC: UIViewController {
    
    @IBOutlet private weak var detailLabel: UILabel!
    
    var commit: CommitMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = commit?.message
    }
    
}
