import UIKit

class BaseScrollDelegateViewController: UIViewController, P_TabBarChildViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - P_TabBarChildViewController
    weak var scrollDelegate: P_TabBarChildViewControllerDelegate!
    func updateScrollContentOffsetIfNeeded(to y: CGFloat, animated: Bool) {
        let contentOffset = CGPoint(x: 0, y: y)
        tableView?.setContentOffset(contentOffset, animated: animated)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = indexPath.description
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.tabBarChildViewController(self, scrollViewDidScroll: scrollView)
    }
    
}

final class ViewController0: BaseScrollDelegateViewController {


}

final class ViewController1: BaseScrollDelegateViewController {

    

}

final class ViewController2: UIViewController {

    let keyboardDismissGestureRecognizer: UIGestureRecognizer = UITapGestureRecognizer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginKeyboardObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endKeyboardObserving()
    }
    
    let database = DatabaseClient { result in
        switch result {
        case .success(let client):
            break
        case .failure(let error):
            print(error)
        }
    }
    
}

private extension ViewController2 {
    
    @IBAction func openCommitsVC() {
        let vc = GithubCommitsVC(
            databaseCommitService: DatabaseCommitService<DatabaseAuthorService>(client: database),
            networkCommitService: GithubService(networkClient: NetworkClient())
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func pushViewController3() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController3")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func pushViewController4() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController4")
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController2: P_KeyboardObservableWithDismiss {
    
    var keyboardObserveOptions: KeyboardObservableOptions { .showHide }
    
}

