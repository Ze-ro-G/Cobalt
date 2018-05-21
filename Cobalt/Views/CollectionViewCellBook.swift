//
//  CollectionViewCellBook.swift
//  Cobalt
//
//  Created by ingouackaz on 07/03/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse

class CollectionViewCellBook: UICollectionViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewCover: UIImageView!

    
    func configure(book:PFBook){
        self.labelTitle.text = book.title

        book.coverImage?.getDataInBackground(block: { (imageData, error) in
            if error == nil {
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        // Run UI Updates or call completion block
                        self.imageViewCover.image = UIImage(data:imageData)
                    }
                }
            }
        })
    }
}
