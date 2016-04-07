//
//  Show+CoreDataProperties.swift
//  TopShow
//
//  Created by Jared Franzone on 1/14/16.
//  Copyright © 2016 Jared Franzone. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Show {

    @NSManaged var title: String?
    @NSManaged var rating: Int32
    @NSManaged var dateAdded: NSDate?

}
