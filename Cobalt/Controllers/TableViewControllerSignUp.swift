//
//  TableViewControllerSignUp.swift
//  Cobalt
//
//  Created by ingouackaz on 07/03/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse

class TableViewControllerSignUp: UITableViewController {
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        initUI()
    }
    
    func initUI(){
        let imageView =  UIImageView(image:#imageLiteral(resourceName: "tribal"))
        imageView.alpha = 0.02
        tableView.backgroundView = imageView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    @IBAction func btnSignUpPressed(){
        startSignUpRequest()
    }
    
    func startSignUpRequest(){
        
        let newUser = PFUser()
        
        newUser.username = textFieldUsername.text
        newUser.password = textFieldPassword.text
        
        newUser.signUpInBackground { (succeeded, error) in
            if succeeded {
                print("Sign up succeeded")
                appD.exitLoginMode()
                // perform segue ?
            }
            else if let signupError = error {
                displayAlertIn(
                    vc: self,
                    title: "Erreur",
                    message: (error?.localizedDescription)!,
                    buttonText: "OK")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textFieldUsername.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
    }
    
    @IBAction func btnBackPressed(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension TableViewControllerSignUp : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
