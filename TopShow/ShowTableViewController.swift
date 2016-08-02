//
//  ShowTableViewController.swift
//  TopShow
//
//  Created by Jared Franzone
//  Copyright © 2016 Jared Franzone. All rights reserved.
//

import UIKit
import CoreData

final class ShowTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - ShowTableViewController
    
    // Get a reference to the NSManagedObjectContext
    // through the persistentContainer in the AppDelegate.
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared().delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    // We are using an NSFetchedResultsController to magage the content of our TableView.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Show> = {
        
        // Create fetch request and the sort descriptor.
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        
        let sortDescriptor = SortDescriptor(key: "rating", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Get reference to managed context.
        let context = self.getContext()
        
        // Create the fetched results controller and set delegate
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context
            , sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("performFetch() failed: \(error)")
        }
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        // update the tableView with the appropriate change
        switch type {
            case .delete:
                self.tableView.deleteRows(at: [indexPath!], with: .fade)
           
            case .update:
                self.configureCell(cell: tableView.cellForRow(at: indexPath!)!, indexPath: indexPath!)
            
            case .insert:
                self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            
            case .move:
                self.tableView.deleteRows(at: [indexPath!], with: .fade)
                self.tableView.insertRows(at: [indexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // If we want to delete a show
        if editingStyle == .delete {
            
            // get the show we want to delete
            let showToDelete = fetchedResultsController.object(at: indexPath as IndexPath)
            
            // get a reference to our managed object context
            let context = self.getContext()
            
            // delete it
            context.delete(showToDelete)
            
            // try and save the change to our Core Data store.
            do {
                try context.save()
            } catch {
                fatalError("save() failed: \(error)")
            }
        }
        
    }

    // MARK: - UITableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if there are no section then return 0
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCellReuseIdentifier", for: indexPath)
        self.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        // Get the show at this index
        let show = self.fetchedResultsController.object(at: indexPath as IndexPath) as Show
        
        // unwrap its data
        if let title = show.title, let rating = show.rating?.intValue {
            cell.textLabel?.text = "\"\(title)\""
            cell.detailTextLabel?.text = String(repeating: "★" as Character, count: rating)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.03921568627, green: 0.3333333333, blue: 0.8784313725, alpha: 1)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "edit" {
            
            if let viewController = segue.destinationViewController as? AddEditViewController {
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedObject = fetchedResultsController.object(at: indexPath)
                    viewController.show = selectedObject
                }
            }
        }
    }
    
    
}




