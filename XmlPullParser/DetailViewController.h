//
//  DetailViewController.h
//  XmlPullParser
//
//  Created by Hoshi Takanori on 11/12/07.
//  Copyright (c) 2011 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextView *textView;

- (id)initWithDictionary:(NSDictionary *)newItem;

@end
