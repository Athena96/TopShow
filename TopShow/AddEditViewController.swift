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

    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let title = show?.title, let rating = show?.rating {

            titleTextField.text = title
            ratingSegmentedControl.selectedSegmentIndex = rating.intValue - 1
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
            if show == nil {
                save()
            } else {
                edit()
            }
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func save()   {
        // Invalid?
        guard let title = titleTextField.text , !title.isEmpty else {
            return
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
            dismiss(animated: true, completion: nil)
        } catch {
            fatalError("save() failed: \(error)")
        }
    }
    
    private func edit() {
        // Invalid?
        guard let title = titleTextField.text , !title.isEmpty else {
            return
        }
        
        if let showToEdit = show {
            
            // Update the selected task
            showToEdit.title = title
            showToEdit.rating = NSNumber(integerLiteral: ratingSegmentedControl.selectedSegmentIndex + 1)
            
            do {
                let context = getContext()
                try context.save()
                
                dismiss(animated: true, completion: nil)
            } catch {
                fatalError("save() failed: \(error)")
            }
        }
    }
    
}
