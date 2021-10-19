//
//  ViewController.swift
//  poiDemo
//
//  Created by 李荣潭 on 2021/10/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tap(_ sender: UIButton) {
        let vc = CommonSiteSelectionMapViewController.init(siteValue: nil) { value in
            
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    

}

