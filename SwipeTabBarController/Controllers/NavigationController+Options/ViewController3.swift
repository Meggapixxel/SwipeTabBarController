//
//  ViewController3.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

final class ViewController3: UIViewController, P_UmicoNavigationControllerChild {
    
    var navigationBarHidden: Bool { false }
    var navigationBarItems: UmicoViewControllerNavigationBarItems { .all }
    
    @IBAction private func pushViewController3() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController3")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func pushViewController4() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController4")
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
