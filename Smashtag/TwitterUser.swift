//
//  TwitterUser.swift
//  Smashtag
//
//  Created by Terrill Thorne on 5/23/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit
import CoreData
//import Twitter

class TwitterUser: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TwitterUser> {
        return NSFetchRequest<TwitterUser>(entityName: "TwitterUser")
    }
}

// MARK: Generated accessors for tweets
extension TwitterUser {
    
    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: Tweet)
    
    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: Tweet)
    
    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)
    
    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)
    
    static func findOrCreateTweet(matching twitterInfo: Twitter.User, in context: NSManagedObjectContext) throws -> TwitterUser
    {
        // go find this tweet
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest() // go find the tweet
        request.predicate = NSPredicate(format: "handle == %@", twitterInfo.screenName) // looking for an unique key for what the person passed in. "This refers to "@" someone on twitter
        
        do {
            
        let matches = try context.fetch(request) // this throws. Matches in an array of tweet
        if matches.count > 0 { // if match is greater than 0, than you've found your tweet
        assert(matches.count == 1, "Tweet.findOrCreateTweet --  database inconsistency") // if matches.count is greater than 1
        return matches[0]
            
            }
            
        } catch { // catch is here if a request to the database fails
            
            throw error // this rethrows the findOrCreateTweet
        }
        let twitterUser = TwitterUser(context: context)
        twitterUser.handle = twitterInfo.screenName
        twitterUser.name   = twitterInfo.name
        
        return twitterUser
        
    }

    
}
