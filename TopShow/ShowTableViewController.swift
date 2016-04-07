
import UIKit
import CoreData

final class ShowTablewViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Variables
    
    // 1)
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    //2)
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // create fetch request and the sort descriptor
        let fetchRequest = NSFetchRequest(entityName: "Show")

        let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
            
        fetchRequest.sortDescriptors = [sortDescriptor]

        // create the fetched results controller and set delegate
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext
            , sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform Fetch
        // You should really fetch this data asyncronously
        // but in our app we will likely not have very much data to fetch...
        // so to simplify things, we will syncronoulsy (that means that things stop till out data is fetched)
        do {
            try fetchedResultsController.performFetch()
        } catch { print("error") }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - NSFetchedResultsController Delegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    
    /*
        Called when changes or additions are made to the NSManagedObjectContext.
        Then the changes made in core data are reflected in the UITableView
    */
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if type == .Insert, let newindexpath = newIndexPath {
            self.tableView.insertRowsAtIndexPaths([newindexpath], withRowAnimation: .Fade)
        } else {
    
            if let indexpath = indexPath {
    
                switch type {
                case .Delete:
                    self.tableView.deleteRowsAtIndexPaths([indexpath], withRowAnimation: .Fade)
                case .Update:
                    self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
                case .Move:
                    self.tableView.deleteRowsAtIndexPaths([indexpath], withRowAnimation: .Fade)
                    self.tableView.insertRowsAtIndexPaths([indexpath], withRowAnimation: .Fade)
                default:
                    print("error")
                }
            }
        }
        
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    // MARK: - TabelView Datasource Methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections {
            let count = sectionInfo[section].numberOfObjects
            return count
        } else {
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShowCellReuseIdentifier", forIndexPath: indexPath)
        self.configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let showToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as? Show  else {
                print("error")
                return
            }
    
            managedObjectContext.deleteObject(showToDelete)
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Error saving context after delete: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    // MARK: - Helper
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let show = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Show
        
        if let title = show.title {
            cell.textLabel?.text = "\"\(title)\""
            cell.detailTextLabel?.text = formatRating(show.rating)
            // Gold color for stars
            cell.detailTextLabel?.textColor = UIColor(red: 1.0, green: 0.8431, blue: 0.0, alpha: 1.0)
        }
    }
    
    
    func formatRating(rating: Int32) -> String {
        switch rating {
        case 5:  return "★★★★★"
        case 4:  return "★★★★"
        case 3:  return "★★★"
        case 2:  return "★★"
        case 1:  return "★"
        default: return "error"
        }
    }
    
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "edit" {
            
            if let vc = (segue.destinationViewController as? UINavigationController)?.topViewController {
                
                if let viewController = vc as? AddEditViewController {
                
                    if let indexPath = tableView.indexPathForSelectedRow {
                    
                        if let selectedObject = fetchedResultsController.objectAtIndexPath(indexPath) as? Show {
                            viewController.show = selectedObject
                        }
                        
                    }
                }
            }
        }
        
    } // end prepareForSegue() method
    
    
    
} // end class
