//
//  AddEditViewController.swift
//  TopShow
//
//  Created by Jared Franzone
//  Copyright © 2016 Jared Franzone. All rights reserved.
//

import UIKit
import CoreData

final class AddEditViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    
    var show: Show?
    
    private enum Error: ErrorProtocol {
        case InvalidTitle
        case Unknown
    }
    
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared().delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        if let title = show?.title, let rating = show?.rating {
            print("show?????????")

            titleTextField.text = title
            ratingSegmentedControl.selectedSegmentIndex = rating.intValue - 1
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        do {
            if show == nil {
                try save()
            } else {
                try edit()
            }
            dismiss(animated: true, completion: nil)
        } catch {
            print("Invalid Input")
        }

    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func save() throws  {
        // Invalid?
        guard let title = titleTextField.text , !title.isEmpty else {
            throw Error.InvalidTitle
        }
        
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Show", in: context)
        let favoriteShow = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        favoriteShow.setValue(title, forKey: "title")
        favoriteShow.setValue(ratingSegmentedControl.selectedSegmentIndex + 1, forKey: "rating")
        favoriteShow.setValue(Date(), forKey: "dateAdded")
        
        do {
            try context.save()
        } catch {
            fatalError("save() failed: \(error)")
        }
    }
    
    private func edit() throws {
        // Invalid?
        guard let title = titleTextField.text , !title.isEmpty else {
            throw Error.InvalidTitle
        }
        
        if let showToEdit = show {
            
            // Update the selected task
            showToEdit.title = title
            showToEdit.rating = ratingSegmentedControl.selectedSegmentIndex + 1
            
            do {
                let context = getContext()
                try context.save()
            } catch {
                fatalError("save() failed: \(error)")
            }
            
        } else {
            throw Error.Unknown
        }
    }
    
}
