//
//  ViewController.swift
//  TNTransition
//
//  Created by 涂育旺 on 2017/12/20.
//  Copyright © 2017年 com.person. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var circleFromView: UIImageView!
    @IBOutlet weak var fromView: UIImageView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tn_setup()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        circleFromView.layer.cornerRadius = circleFromView.frame.height/2
        circleFromView.layer.masksToBounds = true
    }
    
    @IBAction func JumpToDetailVC(_ sender: UITapGestureRecognizer) {
        let type = TNTransitionType.magic(reverse: false)
        tn_transition(by: type, from: fromView, to: "toView")
        push(type: type)
    }
    
    @IBAction func JumpToDetailByCircle(_ sender: UITapGestureRecognizer) {
        let type = TNTransitionType.circle(reverse: false)
        tn_transition(by: type, from: circleFromView)
        push(type: type)
    }
    
    @IBAction func JumpToDetailByPage(_ sender: Any) {
        let type = TNTransitionType.page(reverse: false)
        tn_transition(by: type)
        push(type: type)
    }
    
    fileprivate func push(type: TNTransitionType){
        let detailVC = DetailViewController()
        detailVC.type = type
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

