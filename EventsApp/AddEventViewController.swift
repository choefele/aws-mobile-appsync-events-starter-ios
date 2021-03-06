//
//  NewPostViewController.swift
//  EventsApp
//

import Foundation
import UIKit
import AWSAppSync

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var descriptionInput: UITextField!
    @IBOutlet weak var whenInput: UITextField!
    @IBOutlet weak var whereInput: UITextField!
    var appSyncClient: AWSAppSyncClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewPost(_ sender: Any) {
        // Create a GraphQL mutation
        let addEventMutation = AddEventMutation(name: nameInput.text!,
                                                when: whenInput.text!,
                                                where: whereInput.text!,
                                                description: descriptionInput.text!)
        
        appSyncClient?.perform(mutation: addEventMutation, optimisticUpdate: { (transaction) in
            do {
                // Update our normalized local store immediately for a responsive UI.
                try transaction?.update(query: ListEventsQuery()) { (data: inout ListEventsQuery.Data) in
                    data.listEvents?.items?.append(ListEventsQuery.Data.ListEvent.Item(id: "-1",
                                                                                       description: self.descriptionInput.text,
                                                                                       name: self.nameInput.text,
                                                                                       when: self.whenInput.text,
                                                                                       where: self.whereInput.text,
                                                                                       comments: nil))
                    
                }
            } catch {
                print("Error updating the cache with optimistic response.")
            }
        }) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
