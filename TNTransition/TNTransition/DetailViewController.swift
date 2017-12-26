//
//  DetailViewController.swift
//  TNTransition
//
//  Created by 涂育旺 on 2017/12/21.
//  Copyright © 2017年 com.person. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var toView: UIImageView!
    var type: TNTransitionType!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tn.setup()

        switch type as TNTransitionType {
        case .magic(_):
            tn.transition(by: .magic(reverse: true))
            break
        case .circle(_):
            tn.transition(by: .circle(reverse: true))
            break
        case .page(_):
            tn.transition(by: .page(reverse: true))
            break
        }
        
}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
