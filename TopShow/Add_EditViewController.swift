
import UIKit
import CoreData

class Add_EditViewController: UIViewController {
    
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    
    
    @IBOutlet weak var ratingSegmentedController: UISegmentedControl!
    
    
    
    // MARK: - Error Type(s)
    
    enum Error: ErrorType { case InvalidTitle }
    
    
    
    // MARK: - Variables
    
    var show: Show?
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        If a show object was passed from the table view, a row was selected,
        then display that data in the view (so it can be edited if desired)
        */
        if let title = show?.title, let rating = show?.rating {
            titleTextField.text = title
            ratingSegmentedController.selectedSegmentIndex = rating.integerValue - 1
        }
    }
    
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    
    
    // MARK: - IBActions
    
    /*
    Closes the view controller
    */
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        do {
            if show == nil {
                try save()
            } else {
                try edit()
            }
            dismissViewControllerAnimated(true, completion: nil)
        } catch { print("Invalid Input") }
        
    } // end save button method
    
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: - Helper Methods
    
    /*
        Tries to get valid data from titleTextField.
        If successful, a new "Show" object is created and stored.
        If un-successfil, an error is thrown.
    */
    func save() throws  {
        // Invalid?
        guard let title = titleTextField.text where !title.isEmpty else {
            throw Error.InvalidTitle
        }
        
        // Create and Save
        let favoriteShow = NSEntityDescription.insertNewObjectForEntityForName("Show", inManagedObjectContext: self.managedObjectContext) as! Show
        favoriteShow.title = title
        favoriteShow.rating = ratingSegmentedController.selectedSegmentIndex + 1
        favoriteShow.dateAdded = NSDate()
        
        saveManagedObjectContext()
    }
    
    
    /*
        Tries to get valid data from titleTextField.
        If successful, the show object that was passed is updated with the current data inputed by the user.
        If un-successfil, an error is thrown.
    */
    func edit() throws {
        // Invalid?
        guard let title = titleTextField.text where !title.isEmpty else {
            throw Error.InvalidTitle
        }
        
        // Update the selected task
        show!.title = title
        show!.rating = ratingSegmentedController.selectedSegmentIndex + 1
        
        saveManagedObjectContext()
    }
    
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext.save()
        } catch { print("error saving context") }
    }
    
    
    
} // end class
