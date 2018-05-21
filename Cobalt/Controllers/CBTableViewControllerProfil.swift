//
//  CBTableViewControllerProfil.swift
//  Cobalt
//
//  Created by ingouackaz on 21/05/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse

class CBTableViewControllerProfil: UITableViewController {

    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var imageViewProfil: UIImageView!
    
    @IBOutlet weak var labelBookNumberAdded: UITextField!
    @IBOutlet weak var labelBookNumberRead: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
initUI()
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    func initUI(){
        self.tableView.tableFooterView = UIView()
    }
    func initData(){
        
        if let name = PFUser.current()?.object(forKey: "name"){
            self.labelUserName.text = name as! String

        }
        else {
            self.labelUserName.text = PFUser.current()?.username
        }
    }
    
    @IBAction func btnLogoutPressed(){
        PFUser.logOutInBackground { (error) in
            appD.checkStoryboardMode()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            PFUser.logOutInBackground { (error) in
                appD.checkStoryboardMode()
            }
        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
