//
//  UViewControllerProfil.swift
//  Cobalt
//
//  Created by ingouackaz on 07/03/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse

class CBViewControllerProfil: UIViewController {

    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var imageViewProfil: UIImageView!

    @IBOutlet weak var labelBookNumberAdded: UITextField!
    @IBOutlet weak var labelBookNumberRead: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func initData(){
        
        self.labelUserName.text = PFUser.current()?.username
    }
    
    @IBAction func btnLogoutPressed(){
        PFUser.logOutInBackground { (error) in
            appD.checkStoryboardMode()
        }
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
