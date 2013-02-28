//
//  XmlPullParser.h
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
@property (nonatomic, readonly, copy) NSError *error;

- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (id)initWithStream:(NSInputStream *)stream;

- (BOOL)next;
- (NSString *)nextText;

- (void)abort;

- (BOOL)isStartTag;
- (BOOL)isStartTagWithName:(NSString *)tag;
- (BOOL)isEndTagWithName:(NSString *)tag;

@end
