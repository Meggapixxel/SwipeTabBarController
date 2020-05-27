//
//  GithubCommistVC.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 26.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

struct API_Commit: Decodable {
    
    enum RootKeys: String, CodingKey {
        case sha, commit, url = "html_url"
    }
    
    enum CommitKeys: String, CodingKey {
        
        case message
        case committer
        
        enum CommitterKeys: String, CodingKey {
            case date, name
        }
        
    }
    
    let date: Date
    let message: String
    let sha: String
    let url: String
    let author: API_Author
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        sha = try container.decode(String.self, forKey: .sha)
        url = try container.decode(String.self, forKey: .url)
        
        let commitContainer = try container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commit)
        message = try commitContainer.decode(String.self, forKey: .message)
        
        let committerContainer = try commitContainer.nestedContainer(keyedBy: CommitKeys.CommitterKeys.self, forKey: .committer)
        date = try committerContainer.decode(Date.self, forKey: .date)
        
        author = try commitContainer.decode(API_Author.self, forKey: .committer)
    }
    
}
struct API_Author: Decodable {
    
    let name: String
    let email: String
    
}

final class GithubCommistVC: UITableViewController {

    private let fetchApiCommitsRefreshControl = UIRefreshControl()
    
    private let coreDataClient = CoreDataService()
    private var commits = [Commit]()
    private var commitPredicate: NSPredicate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        performSelector(inBackground: #selector(loadSavedData), with: nil)
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
        coreDataClient.container.viewContext.delete(commit)
        commits.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        coreDataClient.saveContext()
    }
    
}

// MARK: - Setup UI
private extension GithubCommistVC {
    
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
private extension GithubCommistVC {
    
    @objc func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = commitPredicate

        defer {
            DispatchQueue.main.async { [unowned self] in
                self.fetchApiCommitsRefreshControl.endRefreshing()
            }
        }
        do {
            commits = try coreDataClient.container.viewContext.fetch(request)
            print("Got \(commits.count) commits")
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits…", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            // CONTAINS - this predicate matches only objects that contain a string somewhere
            // [c] - predicate-speak for "case-insensitive"
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            // BEGINSWITH - matching text must be at the start of a string
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        })
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo)
            self.loadSavedData()
        })
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        })
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func fetchApiCommits() {
        let newestCommitDate = getNewestCommitDate()
        
        guard let string = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!),
            let data = string.data(using: .utf8)
            else { return }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        let apiCommits: [API_Commit]
        do {
            apiCommits = try jsonDecoder.decode([API_Commit].self, from: data)
        } catch {
            return print(error.localizedDescription)
        }
        
        print("Received \(apiCommits.count) new commits.")
        
        DispatchQueue.main.async { [unowned self] in
            apiCommits.forEach { apiCommit in
                let commit = Commit(context: self.coreDataClient.container.viewContext)
                self.configure(commit: commit, usingApiCommit: apiCommit)
            }
            self.coreDataClient.saveContext()
            self.loadSavedData()
        }
    }
    
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()

        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1

        if let commits = try? coreDataClient.container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }

        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    func configure(commit: Commit, usingApiCommit apiCommit: API_Commit) {
        commit.message = apiCommit.message
        commit.sha = apiCommit.sha
        commit.url = apiCommit.url
        commit.date = apiCommit.date
        
        
        let commitAuthor: Author

        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", apiCommit.author.name)
        if let authors = try? coreDataClient.container.viewContext.fetch(authorRequest), let author = authors.first {
            commitAuthor = author
        } else {
            let author = Author(context: coreDataClient.container.viewContext)
            author.name = apiCommit.author.name
            author.email = apiCommit.author.email
            commitAuthor = author
        }
        commit.author = commitAuthor
    }
    
}
extension Date: CVarArg { }

class GithubCommitVC: UIViewController {
    
    @IBOutlet private weak var detailLabel: UILabel!
    
    var commit: Commit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = commit?.message
    }
    
}
