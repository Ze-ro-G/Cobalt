//
//  CBViewControllerSignIn.swift
//  Cobalt
//
//  Created by ingouackaz on 21/05/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse

class CBViewControllerSignIn: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var btnPasswordForgot: UIButton!
    @IBOutlet weak var btnConnect: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBarButtons()
        
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
        

        textFieldEmail.becomeFirstResponder()
    }
    
    func setBarButtons(){
        // Left and Right Bar buttons
        let leftBarImage: UIImage = UIImage(named: "icon-x")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        let barButtonLeft: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 36))
        barButtonLeft.setImage(leftBarImage, for: UIControlState())
        barButtonLeft.tintColor = UIColor.black
        barButtonLeft.addTarget(self, action: #selector(onCloseTap(_:)), for: UIControlEvents.touchUpInside)
        barButtonLeft.contentHorizontalAlignment = .left
        barButtonLeft.tag = 99 // do not change this value. we are adjusting layoutMargin by comparing this value
        
        let leftBarButton: UIBarButtonItem = UIBarButtonItem()
        leftBarButton.customView = barButtonLeft
        
        self.navigationItem.leftBarButtonItems = [leftBarButton]
    }
    
    @objc func onCloseTap(_ sender: UIButton){
        if self.navigationController != nil{
            let vc: UIViewController? = self.navigationController?.popViewController(animated: true)
            if vc == nil{
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == textFieldPassword{
            textField.returnKeyType = .go
        }else{
            textField.returnKeyType = .next
        }
        return true
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        
        if (textFieldEmail.text!.count > 1 && textFieldPassword.text!.count > 1){
            btnConnect.backgroundColor = UIColor(hex: "FF2D55")
        }else{
            btnConnect.backgroundColor = UIColor(hex: "E3E3E3")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldPassword{
            btnConnect.sendActions(for: UIControlEvents.touchUpInside)
        }else{
            if let nextField: UITextField = self.view.viewWithTag(textField.tag + 1) as? UITextField{
                nextField.becomeFirstResponder()
            }
        }
        return false
    }
    
    
    func startLoginRequest(){
        
        PFUser.logInWithUsername(inBackground: textFieldEmail.text!, password: textFieldPassword.text!) { (user, error) in
            if user != nil {
                
                print("connection is a success")
                appD.checkStoryboardMode()
            }
            else if let errorInfo = error {
                displayAlertIn(vc: self, title: "Unable to connect", message: errorInfo.localizedDescription, buttonText: "OK")
            }
        }
    }
    
    @IBAction func btnPasswordPressed(_ sender: UIButton) {
    
    }
    
    @IBAction func btnSignInPressed(_ sender: UIButton) {
        
        startLoginRequest()
    }
    
    
    

}
