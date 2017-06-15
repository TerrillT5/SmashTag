//
//  SmashTweetTableVC.swift
//  Smashtag
//
//  Created by Terrill Thorne on 5/23/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit
import Twitter
import CoreData


class SmashTweetTableVC: TweetTableViewController { // all the smash core data will go in this class instead of the superClass
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer //  the user able to use any database
    
    override func insertTweets(_ newTweets:[Twitter.Tweet]) {
        super.insertTweets(newTweets)
        
        updateDatabase(with: newTweets) // updates the twitter database with tweets 
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("starting database load")
        container?.performBackgroundTask {[weak self] context in
            for twitterInfo in tweets {
                // add tweet
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context) // "_" means to ignore the return value
            }
            try? context.save() // saves the twitter users & tweets
            print("done loading database")
            self?.printDatabaseStatistics()

        }
    }
    
    private func printDatabaseStatistics() { // informs how many tweets & twitterUsers are in the database
        
        if let context = container?.viewContext {
            
            context.perform {       // this makes the code below perform on the main thread
            if Thread.isMainThread {    // to find if something is on the main queue
                print("on main thread")
            } else {
                print("off main thread")
            }
            let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()      // searches for how many tweets there is
            if let tweetCount = (try? context.fetch(request))?.count    // gets the count of tweets
            {
                print("\(tweetCount) tweets")
            }
            if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) { // fetches all twitter users count
                print("\(tweeterCount) Twitter users")
            }
       
      }
            
     }
        
   }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Tweeters Mentioning Search Term" {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText // where you type the search text on twitter
                tweetersTVC.container = container // the reciever looks into the same database that they are being mentioned in 
                
            }
            
        }
    }

}
