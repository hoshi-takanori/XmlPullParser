//
//  XmlPullParser.h
//  XmlPullParser
//
//  Created by Hoshi Takanori on 11/12/07.
//  Copyright (c) 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    XmlPullParserStartDocument,
    XmlPullParserEndDocument,
    XmlPullParserStartTag,
    XmlPullParserEndTag,
    XmlPullParserText,
} XmlPullParserEventType;

@interface XmlPullParser : NSObject

@property (nonatomic, readonly) NSInteger lineNumber;
@property (nonatomic, readonly) NSInteger columnNumber;
@property (nonatomic, readonly) XmlPullParserEventType eventType;
@property (nonatomic, readonly) NSInteger depth;
@property (nonatomic, readonly, copy) NSString *elementName;
@property (nonatomic, readonly, copy) NSDictionary *attributes;
@property (nonatomic, readonly, copy) NSString *text;

- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (id)initWithStream:(NSInputStream *)stream;

- (BOOL)next;
- (NSString *)nextText;

- (BOOL)isStartTag;
- (BOOL)isStartTagWithName:(NSString *)tag;
- (BOOL)isEndTagWithName:(NSString *)tag;

@end
