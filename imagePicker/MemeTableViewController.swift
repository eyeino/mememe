//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ian MacFarlane on 7/11/16.
//  Copyright © 2016 Ian MacFarlane. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes: [Meme] {
        get {
            return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        }
    }
    
    //TODO: Reload tableView when new meme is added to the memes array.
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Table view loaded...")
        self.tableView!.reloadData()
    }
    */
    
    let reuseIdentifier = "MemeTableCell"
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)!
        let meme = memes[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = "\(meme.top), \(meme.bottom)"
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
    
    }
}