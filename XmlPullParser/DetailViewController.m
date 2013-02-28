//
//  DetailViewController.m
//  XmlPullParser
//
//  Copyright (c) 2011 Hoshi Takanori
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
