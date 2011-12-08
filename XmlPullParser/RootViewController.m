//
//  RootViewController.m
//  XmlPullParser
//
//  Created by Hoshi Takanori on 11/12/07.
//  Copyright (c) 2011 -. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "XmlPullParser.h"

#define RSS @"http://developer.apple.com/news/rss/news.rss"

@implementation RootViewController {
    NSMutableArray *items;
}

- (void)loadRSS:(UIBarButtonItem *)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    int limit = sender.tag;

    [items release];
    items = [[NSMutableArray alloc] init];

    XmlPullParser *parser = [[XmlPullParser alloc] initWithContentsOfURL:[NSURL URLWithString:RSS]];
    while ([parser next]) {
        if ([parser isStartTagWithName:@"item"]) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            while ([parser next] && ! [parser isEndTagWithName:@"item"]) {
                if ([parser isStartTag]) {
                    NSString *tag = parser.elementName;
                    if ([tag isEqual:@"title"] || [tag isEqual:@"pubDate"] || [tag isEqual:@"description"]) {
                        NSString *value = [parser nextText];
                        if (value != nil) {
                            [item setObject:value forKey:tag];
                        }
                    }
                }
            }
            if ([item objectForKey:@"title"] != nil) {
                [items addObject:item];
            }
            [item release];

            if (limit > 0 && items.count >= limit) {
                [parser abort];
            }
        }
    }
    if (parser.error != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"XML Parse Error"
                                                            message:parser.error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    [parser release];

    [self.tableView reloadData];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"XmlPullParser Demo";

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:nil
                                                                action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [backItem release];

    UIBarButtonItem *load10Item = [[UIBarButtonItem alloc] initWithTitle:@"10"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(loadRSS:)];
    load10Item.tag = 10;
    self.navigationItem.leftBarButtonItem = load10Item;
    [load10Item release];

    UIBarButtonItem *loadAllItem = [[UIBarButtonItem alloc] initWithTitle:@"All"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(loadRSS:)];
    self.navigationItem.rightBarButtonItem = loadAllItem;
    [loadAllItem release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    id item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.detailTextLabel.text = [item objectForKey:@"pubDate"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [items objectAtIndex:indexPath.row];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithDictionary:item];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [items release];
    [super dealloc];
}

@end
