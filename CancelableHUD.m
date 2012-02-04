//
//  CancelableHUD.m
//  XmlPullParser
//
//  Created by Hoshi Takanori on 12/02/04.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CancelableHUD.h"

#define HUD_WIDTH   120
#define HUD_HEIGHT  120

#define HUD_CORNER  16
#define HUD_ALPHA   0.6

#define CENTER_X    (HUD_WIDTH / 2)
#define SPINNER_Y   (HUD_HEIGHT / 2 - 12)
#define CANCEL_Y    (HUD_HEIGHT - 24)

#define HUD_DELAY   0.2

@interface CancelableHUD () {
    UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

@end

@implementation CancelableHUD

@synthesize target;
@synthesize selector;

static CancelableHUD *sharedHUD;

+ (void)showWithCancelTarget:(id)target selector:(SEL)selector
{
    if (sharedHUD == nil) {
        sharedHUD = [[CancelableHUD alloc] initWithFrame:[UIScreen mainScreen].bounds];
        sharedHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sharedHUD.windowLevel = UIWindowLevelAlert;
        sharedHUD.target = target;
        sharedHUD.selector = selector;

        sharedHUD.hidden = NO;

        [sharedHUD performSelector:@selector(start) withObject:nil afterDelay:HUD_DELAY];
    }
}

+ (void)dismiss
{
    if (sharedHUD != nil) {
        [NSObject cancelPreviousPerformRequestsWithTarget:sharedHUD selector:@selector(start) object:nil];

        sharedHUD.hidden = YES;

        [sharedHUD release];
        sharedHUD = nil;
    }
}

static CGRect center_rect(CGRect bounds, CGFloat width, CGFloat height)
{
    CGFloat x = bounds.origin.x + (bounds.size.width - width) / 2;
    CGFloat y = bounds.origin.y + (bounds.size.height - height) / 2;
    return CGRectMake(x, y, width, height);
}

- (void)start
{
    UIView *hudView = [[UIView alloc] initWithFrame:center_rect(self.bounds, HUD_WIDTH, HUD_HEIGHT)];
    hudView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                               UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:HUD_ALPHA];
    hudView.layer.cornerRadius = HUD_CORNER;
    [self addSubview:hudView];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(CENTER_X, SPINNER_Y);
    spinner.hidesWhenStopped = NO;
    [hudView addSubview:spinner];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    cancelButton.center = CGPointMake(CENTER_X, CANCEL_Y);
    cancelButton.showsTouchWhenHighlighted = YES;
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [hudView addSubview:cancelButton];

    [spinner startAnimating];

    [hudView release];
}

- (void)cancel:(id)sender
{
    [spinner stopAnimating];
    [target performSelector:selector];
}

- (void)dealloc
{
    [spinner release];
    [target release];
    [super dealloc];
}

@end
