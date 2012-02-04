//
//  CancelableHUD.h
//  XmlPullParser
//
//  Created by Hoshi Takanori on 12/02/04.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CancelableHUD : UIWindow

+ (void)showWithCancelTarget:(id)target selector:(SEL)selector;
+ (void)dismiss;

@end
