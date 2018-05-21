//
//  CBViewControllerSignUp.swift
//  Cobalt
//
//  Created by ingouackaz on 21/05/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse

class CBViewControllerSignUp: UIViewController {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldREmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var nextButtonBottomCns: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarButtons()
        
        textFieldEmail.tag = 1
        textFieldREmail.tag = 2
        textFieldPassword.tag = 3
        
        textFieldEmail.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func startSignUpRequest(){
        
        let newUser = PFUser()
        
        newUser.username = textFieldREmail.text
        newUser.password = textFieldPassword.text
        newUser.email = textFieldREmail.text
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func editingChanged(_ sender: Any) {
        
        if (textFieldREmail.text!.count > 1 && textFieldEmail.text!.count > 1 && textFieldPassword.text!.count > 1){
            btnGo.backgroundColor = UIColor(hex: "FF2D55")
        }else{
            btnGo.backgroundColor = UIColor(hex: "E3E3E3")
        } 
    }
    
    //MARK: - keyboardWillShowNotification
    @objc func keyboardWillShowNotification(_ notification: Notification){
        if let value: NSValue = (notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue, !(DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5){
            let rawFrame: CGRect = value.cgRectValue
            let keyboardFrame: CGRect = self.view.convert(rawFrame, from: nil)
            
            self.view.needsUpdateConstraints()
            nextButtonBottomCns.constant = keyboardFrame.height + 15
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - keyboardWillHideNotification
    @objc func keyboardWillHideNotification(_ notification: Notification){
        self.view.needsUpdateConstraints()
        nextButtonBottomCns.constant = 15
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func onNextButtonTap(_ sender: UIButton) {
        startSignUpRequest()
    }
    

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldREmail{
            textField.resignFirstResponder()
            btnGo.sendActions(for: UIControlEvents.touchUpInside)
        }else if let nextField: UITextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField{
            nextField.becomeFirstResponder()
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if (textFieldREmail.text!.count > 1 && textFieldEmail.text!.count > 1 && textFieldREmail.text == textFieldEmail.text){
            btnGo.backgroundColor = UIColor(hex: "FF2D55")
        }else{
            btnGo.backgroundColor = UIColor(hex: "E3E3E3")
        }        
        return true
    }

}
