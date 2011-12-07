//
//  DetailViewController.m
//  XmlPullParser
//
//  Created by Hoshi Takanori on 11/12/07.
//  Copyright (c) 2011 -. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController {
    NSDictionary *item;
}

@synthesize textView;

- (id)initWithDictionary:(NSDictionary *)newItem
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    if (self) {
        item = [newItem retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [item objectForKey:@"title"];

    self.textView.text = [NSString stringWithFormat:@"title: %@\ndate: %@\n\n%@",
                          [item objectForKey:@"title"],
                          [item objectForKey:@"pubDate"],
                          [item objectForKey:@"description"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.textView = nil;
}

- (void)dealloc
{
    [item release];
    [textView release];
    [super dealloc];
}

@end
