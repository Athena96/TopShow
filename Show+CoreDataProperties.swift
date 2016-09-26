//
//  Show+CoreDataProperties.swift
//  TopShow
//
//  Created by Jared Franzone on 8/19/16.
//  Copyright © 2016 Jared Franzone. All rights reserved.
//

import Foundation
import CoreData

extension Show {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Show> {
        return NSFetchRequest<Show>(entityName: "Show");
    }

    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var title: String?

}
