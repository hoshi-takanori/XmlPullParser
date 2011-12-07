//
//  XmlPullParser.m
//  XmlPullParser
//
//  Created by Hoshi Takanori on 11/12/07.
//  Copyright (c) 2011 -. All rights reserved.
//

#import "XmlPullParser.h"

enum {
    XmlPullParserConditionNormal,
    XmlPullParserConditionEvent,
};

@interface XmlPullParser () <NSXMLParserDelegate>

- (void)setEventType:(XmlPullParserEventType)newEventType;

@end

@implementation XmlPullParser {
    NSXMLParser *parser;
    NSConditionLock *conditionLock;
    XmlPullParserEventType eventType;
    NSInteger depth;
    NSString *elementName;
    NSDictionary *attributes;
    NSString *text;
}

@synthesize eventType;
@synthesize depth;
@synthesize elementName;
@synthesize attributes;
@synthesize text;

#pragma mark -

- (id)initWithXMLParser:(NSXMLParser *)newParser
{
    self = [super init];
    if (self != nil) {
        parser = [newParser retain];
        parser.delegate = self;
    }
    return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    return [self initWithXMLParser:[[[NSXMLParser alloc] initWithContentsOfURL:url] autorelease]];
}

- (id)initWithData:(NSData *)data
{
    return [self initWithXMLParser:[[[NSXMLParser alloc] initWithData:data] autorelease]];
}

- (id)initWithStream:(NSInputStream *)stream
{
    return [self initWithXMLParser:[[[NSXMLParser alloc] initWithStream:stream] autorelease]];
}

- (NSInteger)lineNumber
{
    return parser.lineNumber;
}

- (NSInteger)columnNumber
{
    return parser.columnNumber;
}

- (BOOL)next
{
    if (eventType != XmlPullParserEndDocument) {
        if (conditionLock == nil) {
            conditionLock = [[NSConditionLock alloc] initWithCondition:XmlPullParserConditionNormal];
            [self performSelectorInBackground:@selector(parse) withObject:nil];
        } else {
            [conditionLock unlockWithCondition:XmlPullParserConditionNormal];
        }

        [conditionLock lockWhenCondition:XmlPullParserConditionEvent];

        if (eventType == XmlPullParserEndDocument) {
            [conditionLock unlock];
        }
    }

    return eventType != XmlPullParserEndDocument;
}

- (NSString *)nextText
{
    [self next];
    return text;
}

- (BOOL)isStartTag
{
    return eventType == XmlPullParserStartTag;
}

- (BOOL)isStartTagWithName:(NSString *)name
{
    return eventType == XmlPullParserStartTag && [elementName isEqual:name];
}

- (BOOL)isEndTagWithName:(NSString *)name
{
    return eventType == XmlPullParserEndTag && [elementName isEqual:name];
}

#pragma mark -

- (void)parse
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [conditionLock lockWhenCondition:XmlPullParserConditionNormal];
    [parser parse];
    self.eventType = XmlPullParserEndDocument;

    [pool release];
}

- (void)setEventType:(XmlPullParserEventType)newEventType
{
    if (eventType != XmlPullParserEndDocument) {
        eventType = newEventType;

        if (eventType != XmlPullParserStartTag && eventType != XmlPullParserEndTag) {
            [elementName release];
            elementName = nil;
            [attributes release];
            attributes = nil;
        }
        if (eventType != XmlPullParserText) {
            [text release];
            text = nil;
        }

        [conditionLock unlockWithCondition:XmlPullParserConditionEvent];

        if (eventType != XmlPullParserEndDocument) {
            [conditionLock lockWhenCondition:XmlPullParserConditionNormal];
        }
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.eventType = XmlPullParserStartDocument;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)newElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)newAttributes
{
    elementName = [newElementName copy];
    if (newAttributes.count > 0) {
        attributes = [newAttributes copy];
    }
    depth++;
    self.eventType = XmlPullParserStartTag;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)newElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    elementName = [newElementName copy];
    depth--;
    self.eventType = XmlPullParserEndTag;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"ERROR %@", parseError);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    text = [string copy];
    self.eventType = XmlPullParserText;
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    NSLog(@"WHITESPACE");
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    NSLog(@"COMMENT <!--%@-->", comment);
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    text = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    self.eventType = XmlPullParserText;
}

#pragma mark -

- (void)dealloc
{
    [parser release];
    [conditionLock release];
    [elementName release];
    [attributes release];
    [text release];
    [super dealloc];
}

@end
