//
//  RootViewController.m
//  XmlPullParser
//
//  Copyright (c) 2011, 2012 Hoshi Takanori
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "XmlPullParser.h"
#import "CancelableHUD.h"

#define RSS @"http://developer.apple.com/news/rss/news.rss"

@implementation RootViewController {
    NSMutableArray *items;
    int limit;
    BOOL cancel;
}

- (void)loadRSS:(UIBarButtonItem *)sender
{
    [items release];
    items = [[NSMutableArray alloc] init];
    [self.tableView reloadData];

    limit = sender.tag;
    cancel = NO;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [CancelableHUD showWithCancelTarget:self selector:@selector(cancelLoading)];

    [self performSelectorInBackground:@selector(loadRSSAtURL:) withObject:[NSURL URLWithString:RSS]];
}

- (void)cancelLoading
{
    cancel = YES;
}

- (void)loadRSSAtURL:(NSURL *)url
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    XmlPullParser *parser = [[XmlPullParser alloc] initWithContentsOfURL:url];

    int count = 0;
    while (! cancel && [parser next]) {
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
                [self performSelectorOnMainThread:@selector(addItem:) withObject:item waitUntilDone:NO];
            }
            [item release];

            if (limit > 0 && ++count >= limit) {
                [parser abort];
            }
        }
    }

    [self performSelectorOnMainThread:@selector(loadEnded:) withObject:parser.error waitUntilDone:NO];

    [parser release];

    [pool release];
}

- (void)addItem:(NSDictionary *)item
{
    [items addObject:item];
    [self.tableView reloadData];
}

- (void)loadEnded:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [CancelableHUD dismiss];

    if (error != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"XML Parse Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        [alertView release];
    }
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
