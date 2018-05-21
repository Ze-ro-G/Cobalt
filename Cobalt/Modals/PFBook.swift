//
//  PFBook.swift
//  Cobalt
//
//  Created by ingouackaz on 07/03/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit



import UIKit
import Parse
import Bolts


final class PFBook: PFObject, PFSubclassing {
    
    @NSManaged var title : String?
    @NSManaged var subtitle : String?
    @NSManaged var file : PFFile?
    @NSManaged var coverImage : PFFile?

    init(title : String, subtitle:String, file:PFFile,coverImage:PFFile) {
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.file = file
        self.coverImage = coverImage

    }
    
    override init() {
        super.init()
    }
    
    public class func parseClassName() -> String {
        return "Book"
    }
    
    override class func query() -> PFQuery<PFObject>? {
        
        let query = PFQuery(className: PFBook.parseClassName())
        query.order(byDescending: "createdAt")
        query.cachePolicy = .networkOnly
        return query
    }
    
    class func getAllBooks(completion:@escaping (_ succeed:Bool, _ books:[PFBook]?) -> Void){
        
        let query = PFBook.query()
        
        query?.findObjectsInBackground(block: {
            (objects, error) in
            if error == nil {
                completion(true, objects as! [PFBook])
                print(objects!) // Prints nil
            } else {
                completion(false, nil)
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
}
