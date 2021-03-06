//
//  BookOfTheBibleTableViewController.swift
//  Bible was Read
//
//  Created by Geoff Hom on 6/22/18.
//  Copyright © 2018 Geoff Hom. All rights reserved.
//

import UIKit
import CoreData
import os.log

class BookOfTheBibleTableViewController: UITableViewController, BiblePersistentContainerDelegate {
    // MARK: Properties
    
    var biblePersistentContainer: BiblePersistentContainer?
    // Basically a constant, as the value is set by the parent and never changed.
    // Tried this as an IUO, but really didn't like it. (Type-checking was confusing.)

    var booksOfTheBible: [BookOfTheBible]?
    // Initialized in viewDidLoad().
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        os_log("viewDidAppear", log: .default, type: .debug)
        //testing timing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Get table data.
        biblePersistentContainer?.delegate = self
        booksOfTheBible = biblePersistentContainer?.savedBooks()
        
        os_log("viewDidLoad", log: .default, type: .debug)
        //testing timing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        // Story: User marks chapters/verses, then taps back to (eventually) make this view appear.
        // Update the selected row, if any. A nice side effect is that the row is no longer selected (both appearance and in code).
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksOfTheBible?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath)
        // Table-view cells are reused and should be dequeued.

        guard let bookOfTheBible = booksOfTheBible?[indexPath.row] else {
            return cell
        }
        cell.textLabel?.text = bookOfTheBible.name
        // If we can't get % done, then at least return the book's name.
        
        guard let chapters = bookOfTheBible.chapters?.array as? [Chapter] else {
            os_log("Could not get chapters for book.", log: .default, type: .debug)
            return cell
        }
        var totalVerses = 0
//        let totalVerses = 100
        // testing totalVerses attrib; yeah it's faster; TODO: implement this after committing current stuff
        let numVersesRead = bookOfTheBible.numVersesRead
        for chapter in chapters {
            totalVerses += chapter.verses?.count ?? 0
        }
        // TODO: add totalVerses attribute; when making default data, can do that calc.
        // TODO: make new default-data store
        let percentVersesRead = Double(numVersesRead) * 100.0 / Double(totalVerses)
        let percentVersesReadRounded = String(format: "%.0f", percentVersesRead)
        // Percent rounded to nearest integer. E.g., Obadiah with 1/21 should be 5% (4.8%).
        cell.textLabel?.text = "\(bookOfTheBible.name ?? "") (\(percentVersesReadRounded)%)"
        // Text examples: "Genesis (0%)", "Genesis (100%)", "Genesis (4%)".
        /*
         Calculating % read was slow, looping over all verses for all chapters. (1.5 seconds in simulator.) So, we pre-calculate and store numVersesRead for each chapter and book of the Bible (TODO: and totalVerses).
         */
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ShowChapters":
            guard let chapterTableViewController = segue.destination as? ChapterTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            chapterTableViewController.biblePersistentContainer = biblePersistentContainer
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedBookOfTheBible = booksOfTheBible?[indexPath.row]
            chapterTableViewController.bookOfTheBible = selectedBookOfTheBible
            // Set selected book.
        default:
            ()
        }
    }

    // MARK: - BiblePersistentContainerDelegate

    func biblePersistentContainer(_ container: BiblePersistentContainer, didMakeAlert alert: UIAlertController) {
        present(alert, animated: true)
    }
}
