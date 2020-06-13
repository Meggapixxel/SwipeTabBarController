//
//  GithubAuthorCommitVC.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

final class GithubAuthorCommitVC: UIViewController {
    
    @IBOutlet private weak var detailLabel: UILabel!
    
    var commit: CommitDO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = commit?.message
    }
    
}

