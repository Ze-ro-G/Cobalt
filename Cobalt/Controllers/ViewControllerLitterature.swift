//
//  ViewControllerLitterature.swift
//  Cobalt
//
//  Created by ingouackaz on 07/03/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse
import FolioReaderKit


class ViewControllerLitterature: UIViewController {

    
  //  @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var books : [PFBook] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initData(){
        PFBook.getAllBooks { (succed, books) in
            self.books = books!
            self.collectionView.reloadData()
        }
    }
    
    func initUI(){
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Palatino", size: 15)!]

    }
    @IBAction func unwindToLitterature(segue:UIStoryboardSegue) {
        
    }


    func open(path: String) {
        let config = FolioReaderConfig()
        let folioReader = FolioReader()
        folioReader.presentReader(parentViewController: self, withEpubPath: path, andConfig: config)
    }
    

}

extension ViewControllerLitterature : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var book : PFBook = books[indexPath.row]

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCellBook{
            cell.configure(book: book)
            return cell
        }
        
        
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 155, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var book : PFBook = books[indexPath.row]
        
        book.file?.getDataInBackground(block: { (bookData, error) in
            
            let filepath = getDocumentsDirectory().stringByAppendingPathComponent1(path: "\(book.title).epub")
            print("filepath: \(filepath)")
            
            do {
                try bookData?.write(to: URL(fileURLWithPath: filepath), options: .atomic)
            } catch {
                print(error)
            }
            selectedPath = filepath
            self.performSegue(withIdentifier: "reader", sender: nil)
          //  self.open(path: filepath)
        })
    }
    
}



