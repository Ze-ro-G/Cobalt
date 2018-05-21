//
//  CBViewControllerLogin.swift
//  Cobalt
//
//  Created by ingouackaz on 21/05/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4
import JBKenBurnsView

class CBViewControllerLogin: UIViewController {

    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var jkviewBackground: JBKenBurnsView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        jkviewBackground.stopAnimation()
        let imageArray = [UIImage(named:"background2"), UIImage(named:"background3"), UIImage(named:"background4"), UIImage(named:"background5")]
        
        jkviewBackground.animate(withImages: imageArray as Any as! [Any], transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func buttonFacebookConnect(_ sender: Any) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) { (user, error) in
            if (error != nil) {
                Popup.ShowAlert(title: "Error", message: "there was an error during the operation", in:self as UIViewController)
            }
            
            if (FBSDKAccessToken.current() != nil) {
                print("La connexion a marché")
                PFUser.current()?.setObject("Facebook", forKey: "connexionType")
                self.linkFacebook()
            }
        }
        
        
        
    }
    
    func linkFacebook() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        let user = PFUser.current()!

        graphRequest.start { (connection, result, error) in
            let data:[String:AnyObject] = result as! [String : AnyObject]

            if let result = result as? [String: Any] {
                if let email = result["email"] as? String {
                    user.email = email
                }
            }
            if let result = result as? [String: Any] {
                if let name = result["name"] as? String {
                    user["name"] = name
                }
            }

            user.saveInBackground(block: { (succeed, error) in
                appD.exitLoginMode()
            })
        }
        appD.exitLoginMode()

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
