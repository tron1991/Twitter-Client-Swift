//
//  TweetTableViewCell.swift
//  Tags
//
//  Created by Nick on 2015-12-10.
//  Copyright © 2015 Nicholas Ivanecky. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    
    
    
    
    private func updateUI()
    {
        //configure the tweet here
        //reset existing tweet info
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        if let tweet = self.tweet {
            var tweetText = tweet.text
            if tweetTextLabel?.text != nil {
                for _ in tweet.media {
                    tweetText = tweetText + " 😀"
                }
            }
            
            let attributedTweetText = NSMutableAttributedString(string: tweetText)
            attributedTweetText.changeKeywordsColor(tweet.hashtags, color: indexedKeywordColor)
            attributedTweetText.changeKeywordsColor(tweet.urls, color: indexedKeywordColor)
            attributedTweetText.changeKeywordsColor(tweet.userMentions, color: indexedKeywordColor)
            
            tweetTextLabel.attributedText = attributedTweetText
            
            //usernames 
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            // profile image
            fetchProfileImage()
            fetchTweetImage()
        }
    }
    
    func fetchProfileImage()
    {
        if let profileImageURL = tweet!.user.profileImageURL {
            
            let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                
                if let imageData = NSData(contentsOfURL: profileImageURL) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
            
        }
    }
    
    func fetchTweetImage()
    {
        if let tweetImageURL = tweet!.media.first?.url {
            
            let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                
                if let tweetImageData = NSData(contentsOfURL: tweetImageURL) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tweetImageView?.image = UIImage(data: tweetImageData)
                    }
                }
            }
            
        }
    }

    
    func configureTweetDate()
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        tweetCreatedLabel.text = formatter.stringFromDate((tweet?.created)!)
    
    }
}

private var indexedKeywordColor = UIColor(red: 85/255, green: 172/255, blue: 238/255.0, alpha: 1)

private extension NSMutableAttributedString
{
    func changeKeywordsColor(keywords: [Tweet.IndexedKeyword], color: UIColor)
    {
        for keyword in keywords {
            addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
        }
    }
}